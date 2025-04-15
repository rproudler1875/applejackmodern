AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Check if an entity is a door (copied from sh_door_ownership.lua)
local function IsDoor(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    return class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
end

-- Primary attack: Lock the door
function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    local ent = ply:GetEyeTrace().Entity

    if not IsValid(ent) or not IsDoor(ent) then
        ply:ChatPrint("You must be looking at a door!")
        return
    end

    if ent:GetPos():DistToSqr(ply:GetPos()) > 10000 then -- ~100 units
        ply:ChatPrint("You’re too far from the door!")
        return
    end

    if ent:GetNWString("AJMRP_Owner", "") != ply:SteamID() then
        ply:ChatPrint("You don’t own this door!")
        return
    end

    ent:Fire("Lock")
    ply:ChatPrint("Door locked!")
    ent:EmitSound("doors/door_latch1.wav")

    self:SetNextPrimaryFire(CurTime() + 0.5) -- Cooldown
end

-- Secondary attack: Unlock the door
function SWEP:SecondaryAttack()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    local ent = ply:GetEyeTrace().Entity

    if not IsValid(ent) or not IsDoor(ent) then
        ply:ChatPrint("You must be looking at a door!")
        return
    end

    if ent:GetPos():DistToSqr(ply:GetPos()) > 10000 then
        ply:ChatPrint("You’re too far from the door!")
        return
    end

    if ent:GetNWString("AJMRP_Owner", "") != ply:SteamID() then
        ply:ChatPrint("You don’t own this door!")
        return
    end

    ent:Fire("Unlock")
    ply:ChatPrint("Door unlocked!")
    ent:EmitSound("doors/door_latch3.wav")

    self:SetNextSecondaryFire(CurTime() + 0.5) -- Cooldown
end

print("[AJMRP] weapon_ajmrp_keys/init.lua loaded")