local PLAYER = FindMetaTable("Player")

function PLAYER:GetStamina()
    return self:GetNWInt("AJMRP_Stamina", AJMRP.Config.MaxStamina)
end

function PLAYER:SetStamina(amount)
    self:SetNWInt("AJMRP_Stamina", math.Clamp(amount, 0, AJMRP.Config.MaxStamina))
    if amount <= 0 then
        self:SetRunSpeed(self:GetWalkSpeed())
    else
        self:SetRunSpeed(240)
    end
end

hook.Add("Think", "AJMRP_Stamina", function()
    for _, ply in ipairs(player.GetAll()) do
        local stamina = ply:GetStamina()
        local velocity = ply:GetVelocity():Length()
        local isSprinting = ply:KeyDown(IN_SPEED) and velocity > 50 and ply:IsOnGround()
        local isMoving = velocity > 50 and not isSprinting
        local lastAction = ply:GetNWFloat("AJMRP_LastStaminaAction", 0)
        
        if isSprinting and stamina > 0 then
            ply:SetStamina(stamina - AJMRP.Config.StaminaDrain)
            ply:SetNWFloat("AJMRP_LastStaminaAction", CurTime())
        elseif CurTime() - lastAction >= AJMRP.Config.StaminaRegenDelay then
            if isMoving then
                ply:SetStamina(stamina + AJMRP.Config.StaminaRegenMoving)
            else
                ply:SetStamina(stamina + AJMRP.Config.StaminaRegen)
            end
        end
    end
end)

hook.Add("KeyPress", "AJMRP_StaminaJump", function(ply, key)
    if key == IN_JUMP and ply:IsOnGround() then
        local stamina = ply:GetStamina()
        ply:SetStamina(stamina - AJMRP.Config.StaminaJumpCost)
        ply:SetNWFloat("AJMRP_LastStaminaAction", CurTime())
    end
end)

hook.Add("PlayerSpawn", "AJMRP_StaminaInit", function(ply)
    ply:SetStamina(AJMRP.Config.MaxStamina)
    ply:SetRunSpeed(240)
    ply:SetWalkSpeed(160)
end)