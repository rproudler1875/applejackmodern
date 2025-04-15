print("[AJMRP] Loading sh_economy.lua")

AJMRP = AJMRP or {}

local meta = FindMetaTable("Player")

function meta:GetCredits()
    return self:GetNWInt("AJMRP_Credits", 0)
end

function meta:AddCredits(amount)
    if not IsValid(self) then return end
    local current = self:GetCredits()
    self:SetNWInt("AJMRP_Credits", math.max(0, current + amount))
end

function meta:GetInventory()
    if SERVER then
        return self.AJMRP_Inventory or {}
    else
        local json = self:GetNWString("AJMRP_Inventory", "{}")
        return util.JSONToTable(json) or {}
    end
end

function meta:SetInventory(inv)
    if not IsValid(self) then return end
    if SERVER then
        self.AJMRP_Inventory = inv or {}
        self:SetNWString("AJMRP_Inventory", util.TableToJSON(self.AJMRP_Inventory))
    end
end

function meta:AddInventoryItem(item_id, amount)
    if not IsValid(self) then return end
    local inv = self:GetInventory()
    inv[item_id] = (inv[item_id] or 0) + amount
    self:SetInventory(inv)
end

function meta:RemoveInventoryItem(item_id, amount)
    if not IsValid(self) then return end
    local inv = self:GetInventory()
    if inv[item_id] and inv[item_id] >= amount then
        inv[item_id] = inv[item_id] - amount
        if inv[item_id] <= 0 then
            inv[item_id] = nil
        end
        self:SetInventory(inv)
        return true
    end
    return false
end

function meta:LoadEconomy()
    if not IsValid(self) then return end
    
    print("[AJMRP] LoadEconomy for " .. self:Nick())
    
    local steamID = self:SteamID64()
    local path = "ajmrp/player_" .. steamID .. ".txt"
    
    if file.Exists(path, "DATA") then
        local data = util.JSONToTable(file.Read(path, "DATA") or "{}")
        self:SetNWInt("AJMRP_Credits", data.credits or 500)
    else
        self:SetNWInt("AJMRP_Credits", 500)
    end
end

function meta:SaveEconomy()
    if not IsValid(self) then return end
    
    local steamID = self:SteamID64()
    local path = "ajmrp/player_" .. steamID .. ".txt"
    local data = {
        credits = self:GetCredits(),
        inventory = self:GetInventory()
    }
    file.Write(path, util.TableToJSON(data))
end

function meta:LoadInventory()
    if not IsValid(self) then return end
    
    print("[AJMRP] LoadInventory for " .. self:Nick())
    
    local steamID = self:SteamID64()
    local path = "ajmrp/player_" .. steamID .. ".txt"
    
    if file.Exists(path, "DATA") then
        local data = util.JSONToTable(file.Read(path, "DATA") or "{}")
        self:SetInventory(data.inventory or {})
    else
        self:SetInventory({})
    end
end

function meta:SaveInventory()
    if not IsValid(self) then return end
    
    print("[AJMRP] SaveInventory for " .. self:Nick())
    self:SaveEconomy()
end

function AJMRP.BuyItem(ply, item_id)
    print("[AJMRP] BuyItem called for player " .. ply:Nick() .. " with item_id " .. tostring(item_id))
    
    if not IsValid(ply) then
        print("[AJMRP] BuyItem: Player is not valid")
        return false, "Purchase failed: Player is not valid!"
    end
    
    if not AJMRP.Config.Items[item_id] then
        print("[AJMRP] BuyItem: Invalid item ID - " .. tostring(item_id))
        return false, "Invalid item!"
    end
    
    local item = AJMRP.Config.Items[item_id]
    print("[AJMRP] BuyItem: Item - " .. item.name)
    
    local allowed = false
    for _, job in ipairs(item.jobs) do
        if job == ply:GetJob() then
            allowed = true
            break
        end
    end
    
    if not allowed then
        print("[AJMRP] BuyItem: Job restriction failed for " .. ply:GetJob() .. " (required: " .. table.concat(item.jobs, ", ") .. ")")
        return false, "Cannot buy " .. item.name .. ": Restricted to " .. table.concat(item.jobs, ", ") .. "!"
    end
    
    local credits = ply:GetCredits()
    if credits < item.price then
        print("[AJMRP] BuyItem: Not enough credits - " .. credits .. "/" .. item.price)
        return false, "Cannot buy " .. item.name .. ": Need " .. item.price .. " Credits, you have " .. credits .. "!"
    end
    
    -- Deduct Credits
    print("[AJMRP] BuyItem: Deducting " .. item.price .. " credits from " .. ply:Nick())
    ply:AddCredits(-item.price)
    
    -- Handle item
    if item.entity then
        print("[AJMRP] BuyItem: Spawning entity " .. item.entity)
        -- Spawn entity in front of player
        local pos = ply:EyePos()
        local ang = ply:GetAimVector()
        local spawnPos = pos + ang * 250 -- ~2.5m forward
        
        -- Trace to avoid walls
        local tr = util.TraceLine({
            start = pos,
            endpos = spawnPos,
            filter = ply
        })
        
        if tr.Hit then
            spawnPos = tr.HitPos - ang * 10 -- Move back slightly
            print("[AJMRP] BuyItem: Adjusted spawn position due to wall hit")
        end
        
        local success, ent = pcall(ents.Create, item.entity)
        if not success or not IsValid(ent) then
            print("[AJMRP] BuyItem: Failed to create entity - " .. tostring(ent))
            ply:AddCredits(item.price) -- Refund
            return false, "Failed to spawn " .. item.name .. ": Entity '" .. item.entity .. "' could not be created!"
        end
        
        ent:SetPos(spawnPos)
        -- Set the owner for entities like the money printer
        if ent.SetOwner then
            ent:SetOwner(ply)
            print("[AJMRP] BuyItem: SetOwner called for entity")
        elseif ent.Setowning_ent then -- Fallback for some entities
            ent:Setowning_ent(ply)
            print("[AJMRP] BuyItem: Setowning_ent called for entity")
        end
        ent.owner = ply -- Directly set the owner field as per ajmrp_printer/init.lua
        print("[AJMRP] BuyItem: Owner set to " .. ply:Nick())
        
        local spawnSuccess, spawnErr = pcall(function() ent:Spawn() end)
        if not spawnSuccess then
            print("[AJMRP] BuyItem: Spawn failed - " .. tostring(spawnErr))
            ent:Remove()
            ply:AddCredits(item.price) -- Refund
            return false, "Failed to spawn " .. item.name .. ": " .. tostring(spawnErr)
        end
        
        ent:DropToFloor()
        print("[AJMRP] BuyItem: Entity spawned at " .. tostring(spawnPos))
        
        -- Special handling for money printer
        if item.entity == "ajmrp_printer" then
            if IsValid(ply.printer) then
                ply.printer:Remove()
                print("[AJMRP] BuyItem: Removed existing printer for " .. ply:Nick())
            end
            ply.printer = ent
            print("[AJMRP] BuyItem: Assigned new printer to " .. ply:Nick())
        end
    else
        -- Non-entity (e.g., food): Add to inventory
        print("[AJMRP] BuyItem: Adding " .. item_id .. " to inventory")
        ply:AddInventoryItem(item_id, 1)
    end
    
    -- Save after purchase
    print("[AJMRP] BuyItem: Saving economy for " .. ply:Nick())
    ply:SaveEconomy()
    
    print("[AJMRP] BuyItem: Success - Bought " .. item.name .. " for " .. item.price .. " Credits!")
    return true, "Bought " .. item.name .. " for " .. item.price .. " Credits!"
end

net.Receive("AJMRP_BuyItem", function(len, ply)
    print("[AJMRP] Received AJMRP_BuyItem from " .. ply:Nick())
    local item_id = net.ReadString()
    local success, message = AJMRP.BuyItem(ply, item_id)
    
    print("[AJMRP] Sending AJMRP_BuyItemResponse to " .. ply:Nick() .. ": " .. tostring(success) .. " - " .. message)
    net.Start("AJMRP_BuyItemResponse")
    net.WriteBool(success)
    net.WriteString(message)
    net.Send(ply)
end)

if SERVER then
    util.AddNetworkString("AJMRP_UpdateInventory")

    net.Receive("AJMRP_UpdateInventory", function(len, ply)
        print("[AJMRP] Received AJMRP_UpdateInventory from " .. ply:Nick())
        local newInventory = net.ReadTable()
        ply:SetInventory(newInventory)
        ply:SaveInventory()
        ply:ChatPrint("Inventory updated!")
    end)
end

print("[AJMRP] sh_economy.lua loaded")