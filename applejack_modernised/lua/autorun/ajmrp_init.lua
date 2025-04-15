if SERVER then
    AddCSLuaFile()
    
    -- Precache models
    util.PrecacheModel("models/props_c17/console01a.mdl")
    
    -- Network strings
    util.AddNetworkString("AJMRP_CharacterCreation")
    util.AddNetworkString("AJMRP_SwitchJob")
    util.AddNetworkString("AJMRP_BuyItem")
    util.AddNetworkString("AJMRP_SellItem")
    util.AddNetworkString("AJMRP_ProposeTrade")
    util.AddNetworkString("AJMRP_TradeRequest")
    util.AddNetworkString("AJMRP_AcceptTrade")
end