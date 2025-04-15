ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Medkit"
ENT.Category = "AppleJack Modernised RP"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "HealAmount")
end