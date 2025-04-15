ENT.Type = "anim"
ENT.Base = scripted_ents.Get("base_gmodentity") and "base_gmodentity" or "base_anim"
ENT.PrintName = "Money Printer"
ENT.Author = "Grok"
ENT.Spawnable = true
ENT.Category = "AppleJack RP"

function ENT:SetupDataTables()
    print("[AJMRP] Setting up DataTables for ajmrp_printer")
    self:NetworkVar("Int", 0, "Credits")
    self:NetworkVar("Entity", 0, "Owner")
end

if SERVER then
    print("[AJMRP] ajmrp_printer shared.lua loaded on server")
else
    print("[AJMRP] ajmrp_printer shared.lua loaded on client")
end

print("[AJMRP] ajmrp_printer using base: " .. ENT.Base)