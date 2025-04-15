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
    if not IsValid(ply) or not AJMRP.Config.Items[item_id] then
        return false, "Invalid item!"
    end
    
    local item = AJMRP.Config.Items[item_id]
    local allowed = false
    for _, job in ipairs(item.jobs) do
        if job == ply:GetJob() then
            allowed = true
            break
        end
    end
    
    if not allowed then
        return false, "Cannot buy " .. item.name .. ": Restricted to " .. table.concat(item.jobs, ", ") .. "!"
    end
    
    local credits = ply:GetCredits()
    if credits < item.price then
        return false, "Cannot buy " .. item.name .. ": Need " .. item.price .. " Credits, you have " .. credits .. "!"
    end
    
    -- Deduct Credits
    ply:AddCredits(-item.price)
    
    -- Handle item
    if item.entity then
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
        end
        
        local ent = ents.Create(item.entity)
        if not IsValid(ent) then
            ply:AddCredits(item.price) -- Refund
            return false, "Failed to spawn " .. item.name .. ": Entity '" .. item.entity .. "' could not be created!"
        end
        
        ent:SetPos(spawnPos)
        -- Set the owner for entities like the money printer
        if ent.SetOwner then
            ent:SetOwner(ply)
        elseif ent.Setowning_ent then -- Fallback for some entities
            ent:Setowning_ent(ply)
        end
        ent.owner = ply -- Directly set the owner field as per ajmrp_printer/init.lua
        ent:Spawn()
        ent:DropToFloor()
        
        -- Special handling for money printer
        if item.entity == "ajmrp_printer" then
            if IsValid(ply.printer) then
                ply.printer:Remove() -- Remove existing printer if any
            end
            ply.printer = ent -- Assign the new printer to the player
        end
    else
        -- Non-entity (e.g., food): Add to inventory
        ply:AddInventoryItem(item_id, 1)
    end
    
    -- Save after purchase
    ply:SaveEconomy()
    
    return true, "Bought " .. item.name .. " for " .. item.price .. " Credits!"
end

net.Receive("AJMRP_BuyItem", function(len, ply)
    local item_id = net.ReadString()
    local success, message = AJMRP.BuyItem(ply, item_id)
    
    net.Start("AJMRP_BuyItemResponse")
    net.WriteBool(success)
    net.WriteString(message)
    net.Send(ply)
end)

if SERVER then
    util.AddNetworkString("AJMRP_UpdateInventory")

    net.Receive("AJMRP_UpdateInventory", function(len, ply)
        local newInventory = net.ReadTable()
        ply:SetInventory(newInventory)
        ply:SaveInventory()
        ply:ChatPrint("Inventory updated!")
    end)
end

print("[AJMRP] sh_economy.lua loaded")
