AJMRP = AJMRP or {}

local meta = FindMetaTable("Player")

function meta:GetHunger()
    return self:GetNWInt("AJMRP_Hunger", AJMRP.Config.MaxHunger)
end

function meta:SetHunger(amount)
    self:SetNWInt("AJMRP_Hunger", math.Clamp(amount, 0, AJMRP.Config.MaxHunger))
end

function meta:AddHunger(amount)
    local current = self:GetHunger()
    self:SetHunger(current + amount)
end

if SERVER then
    timer.Create("AJMRP_HungerDrain", 1, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) then continue end
            
            local hunger = ply:GetHunger()
            if hunger <= 0 then
                -- Apply damage when hunger is 0
                local dmg = DamageInfo()
                dmg:SetDamage(1)
                dmg:SetDamageType(DMG_STARVATION)
                dmg:SetAttacker(ply)
                dmg:SetInflictor(ply)
                ply:TakeDamageInfo(dmg)
            else
                ply:AddHunger(-AJMRP.Config.HungerDrain)
            end
        end
    end)
end

print("[AJMRP] sh_hunger.lua loaded")