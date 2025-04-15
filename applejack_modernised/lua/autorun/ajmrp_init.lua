if SERVER then
    AddCSLuaFile()
    
    -- Precache models
    util.PrecacheModel("models/props_c17/console01a.mdl")
    util.PrecacheModel("models/weapons/v_hands.mdl") -- For keys
    
    -- Network strings
    util.AddNetworkString("AJMRP_CharacterCreation")
    util.AddNetworkString("AJMRP_SwitchJob")
    util.AddNetworkString("AJMRP_BuyItem")
    util.AddNetworkString("AJMRP_SellItem")
    util.AddNetworkString("AJMRP_ProposeTrade")
    util.AddNetworkString("AJMRP_TradeRequest")
    util.AddNetworkString("AJMRP_AcceptTrade")
    
    -- Include weapon files
    AddCSLuaFile("../entities/weapons/weapon_ajmrp_keys/cl_init.lua")
    AddCSLuaFile("../entities/weapons/weapon_ajmrp_keys/shared.lua")
end

print("[AJMRP] ajmrp_init.lua loaded")