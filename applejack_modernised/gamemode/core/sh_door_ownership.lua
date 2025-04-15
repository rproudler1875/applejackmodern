-- AppleJack Modernised RP: Door Ownership System
AJMRP = AJMRP or {}

-- Persistent door data storage
local doorData = {}
local lastParentKey = nil -- Tracks the last parent door set by an admin
local DATA_PATH = "applejack_modernised/doors.txt"

-- Generate a unique key for a door based on its position and angles
local function GetDoorKey(ent)
    if not IsValid(ent) then return nil end
    local pos = ent:GetPos()
    local ang = ent:GetAngles()
    return string.format("%f_%f_%f_%f_%f_%f", pos.x, pos.y, pos.z, ang.p, ang.y, ang.r)
end

-- Check if an entity is a door
local function IsDoor(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    return class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
end

-- Load door data from file
local function LoadDoorData()
    if file.Exists(DATA_PATH, "DATA") then
        doorData = util.JSONToTable(file.Read(DATA_PATH, "DATA")) or {}
        print("[AJMRP] Loaded door data for " .. table.Count(doorData) .. " doors")
    else
        doorData = {}
        print("[AJMRP] No door data found, starting fresh")
    end
end

-- Save door data to file
local function SaveDoorData()
    file.Write(DATA_PATH, util.TableToJSON(doorData))
    print("[AJMRP] Saved door data for " .. table.Count(doorData) .. " doors")
end

-- Apply door data to entities on map load
local function ApplyDoorData()
    for _, ent in ipairs(ents.FindByClass("func_door*")) do
        local key = GetDoorKey(ent)
        if key and doorData[key] then
            ent:SetNWString("AJMRP_Owner", doorData[key].owner or "")
            ent:SetNWString("AJMRP_DoorName", doorData[key].name or "")
            ent:SetNWBool("AJMRP_IsParent", doorData[key].isParent or false)
        end
    end
end

-- Initialize door system
if SERVER then
    hook.Add("InitPostEntity", "AJMRP_DoorInit", function()
        LoadDoorData()
        ApplyDoorData()
    end)
end

-- Check if a door can be purchased
function AJMRP.CanBuyDoor(ply, ent)
    if not IsValid(ent) or not IsDoor(ent) then
        return false, "Not a valid door!"
    end
    if not ent:GetNWBool("AJMRP_IsParent") then
        return false, "Only parent doors can be purchased!"
    end
    if ent:GetNWString("AJMRP_Owner") != "" then
        return false, "Door is already owned!"
    end
    if ply:GetCredits() < AJMRP.Config.DoorPrice then
        return false, "Need " .. AJMRP.Config.DoorPrice .. " Credits!"
    end
    return true
end

-- Set ownership for a parent door and its children
local function SetDoorOwnership(parentEnt, ownerSteamID)
    local parentKey = GetDoorKey(parentEnt)
    if not parentKey or not doorData[parentKey] then return end

    -- Set owner for parent
    parentEnt:SetNWString("AJMRP_Owner", ownerSteamID)
    doorData[parentKey].owner = ownerSteamID
    print("[AJMRP] Set owner for parent door " .. (doorData[parentKey].name or parentKey) .. " to " .. ownerSteamID)

    -- Find and set owner for children
    for key, data in pairs(doorData) do
        if data.parentKey == parentKey then
            for _, ent in ipairs(ents.FindByClass("func_door*")) do
                if GetDoorKey(ent) == key then
                    ent:SetNWString("AJMRP_Owner", ownerSteamID)
                    doorData[key].owner = ownerSteamID
                    print("[AJMRP] Set owner for child door " .. (data.name or key) .. " to " .. ownerSteamID)
                    break
                end
            end
        end
    end

    SaveDoorData()
end

-- Clear ownership for a parent door and its children
local function ClearDoorOwnership(parentEnt)
    local parentKey = GetDoorKey(parentEnt)
    if not parentKey or not doorData[parentKey] then return end

    -- Clear owner for parent
    parentEnt:SetNWString("AJMRP_Owner", "")
    doorData[parentKey].owner = ""
    print("[AJMRP] Cleared owner for parent door " .. (doorData[parentKey].name or parentKey))

    -- Clear owner for children
    for key, data in pairs(doorData) do
        if data.parentKey == parentKey then
            for _, ent in ipairs(ents.FindByClass("func_door*")) do
                if GetDoorKey(ent) == key then
                    ent:SetNWString("AJMRP_Owner", "")
                    doorData[key].owner = ""
                    print("[AJMRP] Cleared owner for child door " .. (data.name or key))
                    break
                end
            end
        end
    end

    SaveDoorData()
end

if SERVER then
    util.AddNetworkString("AJMRP_BuyDoor")
    util.AddNetworkString("AJMRP_UnbuyDoor")
    util.AddNetworkString("AJMRP_SetParentDoor")
    util.AddNetworkString("AJMRP_SetChildDoor")

    -- Buy door command
    concommand.Add("ajmrp_buy_door", function(ply)
        local ent = ply:GetEyeTrace().Entity
        local canBuy, err = AJMRP.CanBuyDoor(ply, ent)
        if not canBuy then
            ply:ChatPrint(err)
            return
        end
        SetDoorOwnership(ent, ply:SteamID())
        ply:AddCredits(-AJMRP.Config.DoorPrice)
        ply:ChatPrint("Purchased door '" .. (ent:GetNWString("AJMRP_DoorName") or "Parent Door") .. "' for " .. AJMRP.Config.DoorPrice .. " Credits!")
    end)

    -- Unbuy door command
    concommand.Add("ajmrp_unbuy_door", function(ply)
        local ent = ply:GetEyeTrace().Entity
        if not IsValid(ent) or not IsDoor(ent) then
            ply:ChatPrint("Not a valid door!")
            return
        end
        if not ent:GetNWBool("AJMRP_IsParent") then
            ply:ChatPrint("Only parent doors can be unowned!")
            return
        end
        if ent:GetNWString("AJMRP_Owner") != ply:SteamID() then
            ply:ChatPrint("You don’t own this door!")
            return
        end
        ClearDoorOwnership(ent)
        ply:ChatPrint("Relinquished ownership of door '" .. (ent:GetNWString("AJMRP_DoorName") or "Parent Door") .. "'!")
    end)

    -- Admin command: /setparent <name>
    hook.Add("PlayerSay", "AJMRP_SetParentCommand", function(ply, text)
        if string.sub(text, 1, 10) == "/setparent" then
            if not ply:IsAdmin() then
                ply:ChatPrint("You must be an admin to use this command!")
                return ""
            end
            local name = string.Trim(string.sub(text, 12))
            if name == "" or string.len(name) > 32 then
                ply:ChatPrint("Name must be 1-32 characters!")
                return ""
            end
            local ent = ply:GetEyeTrace().Entity
            if not IsValid(ent) or not IsDoor(ent) then
                ply:ChatPrint("You must be looking at a door!")
                return ""
            end
            local key = GetDoorKey(ent)
            if not key then
                ply:ChatPrint("Failed to identify door!")
                return ""
            end
            doorData[key] = doorData[key] or {}
            doorData[key].name = name
            doorData[key].isParent = true
            doorData[key].parentKey = nil
            doorData[key].owner = doorData[key].owner or ""
            ent:SetNWString("AJMRP_DoorName", name)
            ent:SetNWBool("AJMRP_IsParent", true)
            lastParentKey = key
            SaveDoorData()
            ply:ChatPrint("Set door as parent named '" .. name .. "'")
            return ""
        end
    end)

    -- Admin command: /setchild <name>
    hook.Add("PlayerSay", "AJMRP_SetChildCommand", function(ply, text)
        if string.sub(text, 1, 9) == "/setchild" then
            if not ply:IsAdmin() then
                ply:ChatPrint("You must be an admin to use this command!")
                return ""
            end
            local name = string.Trim(string.sub(text, 11))
            if name == "" or string.len(name) > 32 then
                ply:ChatPrint("Name must be 1-32 characters!")
                return ""
            end
            if not lastParentKey or not doorData[lastParentKey] then
                ply:ChatPrint("No parent door set! Use /setparent first!")
                return ""
            end
            local ent = ply:GetEyeTrace().Entity
            if not IsValid(ent) or not IsDoor(ent) then
                ply:ChatPrint("You must be looking at a door!")
                return ""
            end
            local key = GetDoorKey(ent)
            if not key then
                ply:ChatPrint("Failed to identify door!")
                return ""
            end
            if key == lastParentKey then
                ply:ChatPrint("A door cannot be a child of itself!")
                return ""
            end
            doorData[key] = doorData[key] or {}
            doorData[key].name = name
            doorData[key].isParent = false
            doorData[key].parentKey = lastParentKey
            doorData[key].owner = doorData[key].owner or ""
            ent:SetNWString("AJMRP_DoorName", name)
            ent:SetNWBool("AJMRP_IsParent", false)
            SaveDoorData()
            ply:ChatPrint("Set door as child named '" .. name .. "' of parent '" .. (doorData[lastParentKey].name or lastParentKey) .. "'")
            return ""
        end
    end)
end

if CLIENT then
    -- Optional: Display door name when looking at a door
    hook.Add("HUDPaint", "AJMRP_DoorInfo", function()
        local ply = LocalPlayer()
        local ent = ply:GetEyeTrace().Entity
        if IsValid(ent) and IsDoor(ent) and ent:GetPos():DistToSqr(ply:GetPos()) < 10000 then -- Within ~100 units
            local name = ent:GetNWString("AJMRP_DoorName", "")
            if name != "" then
                draw.SimpleText("Door: " .. name, "DermaDefault", ScrW() / 2, ScrH() / 2 + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                local owner = ent:GetNWString("AJMRP_Owner", "")
                local status = owner == "" and "Available" or (owner == ply:SteamID() and "Owned by You" or "Owned")
                draw.SimpleText("Status: " .. status, "DermaDefault", ScrW() / 2, ScrH() / 2 + 40, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end)
end

print("[AJMRP] sh_door_ownership.lua loaded")