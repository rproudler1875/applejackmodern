AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("core/sh_config.lua")
AddCSLuaFile("core/sh_character.lua")
AddCSLuaFile("core/sh_door_ownership.lua")
AddCSLuaFile("core/sh_hunger.lua")
AddCSLuaFile("core/sh_stamina.lua")
AddCSLuaFile("core/sh_jobs.lua")
AddCSLuaFile("core/sh_economy.lua")
AddCSLuaFile("core/cl_hud.lua")
AddCSLuaFile("core/cl_menu.lua")

include("shared.lua")
include("core/sh_config.lua")
include("core/sh_character.lua")
include("core/sh_door_ownership.lua")
include("core/sh_hunger.lua")
include("core/sh_stamina.lua")
include("core/sh_jobs.lua")
include("core/sh_economy.lua")

util.AddNetworkString("AJMRP_CharacterCreation")
util.AddNetworkString("AJMRP_SwitchJob")
util.AddNetworkString("AJMRP_BuyItem")
util.AddNetworkString("AJMRP_SellItem")
util.AddNetworkString("AJMRP_ProposeTrade")
util.AddNetworkString("AJMRP_TradeRequest")
util.AddNetworkString("AJMRP_AcceptTrade")
util.AddNetworkString("AJMRP_SyncInventory")

function GM:Initialize()
    print("[AJMRP] AppleJack Modernised RP loaded!")
    spawnmenu.Init() -- Initialize spawn menu system
end

function GM:PlayerInitialSpawn(ply)
    ply:LoadCharacter()
    ply:LoadJob()
    ply:LoadEconomy()
    ply:LoadInventory()
    ply:SetHunger(AJMRP.Config.MaxHunger)
    ply:SetStamina(AJMRP.Config.MaxStamina)
    ply.firstJoin = true
end

function GM:PlayerSpawn(ply)
    self.BaseClass:PlayerSpawn(ply) -- Call sandbox spawn
    ply:Give("weapon_ajmrp_keys") -- Give keys
    ply:Give("weapon_physgun") -- Give physics gun
end

function GM:PlayerDisconnected(ply)
    ply:SaveCharacter()
    ply:SaveJob()
    ply:SaveEconomy()
    ply:SaveInventory()
    if IsValid(ply.printer) then
        ply.printer:Remove()
    end
end

-- Allow all players to use spawn menu
function GM:PlayerSpawnedProp(ply, model, ent)
    return true -- Allow prop spawning
end

function GM:PlayerSpawnedNPC(ply, ent)
    return true
end

function GM:PlayerSpawnedVehicle(ply, ent)
    return true
end

function GM:PlayerSpawnedSENT(ply, ent)
    return true
end

function GM:PlayerSpawnedWeapon(ply, ent)
    return true
end

function GM:PlayerSpawnedEffect(ply, model, ent)
    return true
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
    return true
end

concommand.Add("ajmrp_toggle_hud", function(ply)
    if IsValid(ply) then
        ply:ChatPrint("Use this command in client console to toggle HUD.")
    end
end)
