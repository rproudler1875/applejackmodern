surface.CreateFont("AJMRP_HUD_Title", {
    font = file.Exists("resource/fonts/RobotoCondensed-Regular.ttf", "GAME") and "Roboto Condensed" or "Arial",
    size = 20,
    weight = 700,
    antialias = true
})

surface.CreateFont("AJMRP_HUD_Text", {
    font = file.Exists("resource/fonts/RobotoCondensed-Regular.ttf", "GAME") and "Roboto Condensed" or "Arial",
    size = 16,
    weight = 500,
    antialias = true
})

hook.Add("HUDPaint", "AJMRP_HUD", function()
    if not IsValid(LocalPlayer()) then return end
    
    local ply = LocalPlayer()
    local credits = ply:GetCredits()
    local hunger = ply:GetHunger()
    local stamina = ply:GetStamina()
    local health = ply:Health()
    local name = ply:GetCharacterName() or ply:Nick()
    local job = AJMRP.Config.Jobs[ply:GetJob()] and AJMRP.Config.Jobs[ply:GetJob()].name or "Unknown"
    
    local x, y = ScrW() / 2 - 225, ScrH() - 90
    local width, height = 450, 90
    
    -- Transparent dark gray background
    draw.RoundedBox(8, x, y, width, height, Color(50, 50, 50, 180))
    
    -- Left: Name, Job, Credits
    draw.SimpleText("Character: " .. name, "AJMRP_HUD_Title", x + 10, y + 10, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText("Job: " .. job, "AJMRP_HUD_Text", x + 10, y + 30, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText("Credits: " .. credits, "AJMRP_HUD_Text", x + 10, y + 50, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    
    -- Right: Stamina, Hunger, Health
    local barWidth, barHeight = 100, 10
    local barX = x + 280
    
    -- Stamina Bar
    draw.SimpleText("Stamina: " .. math.floor(stamina) .. "%", "AJMRP_HUD_Text", barX, y + 10, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.RoundedBox(4, barX, y + 28, barWidth, barHeight, Color(50, 50, 50, 200))
    draw.RoundedBox(4, barX, y + 28, barWidth * (stamina / 100), barHeight, Color(0, 200, 0))
    
    -- Hunger Bar
    draw.SimpleText("Hunger: " .. math.floor(hunger) .. "%", "AJMRP_HUD_Text", barX, y + 30, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.RoundedBox(4, barX, y + 48, barWidth, barHeight, Color(50, 50, 50, 200))
    draw.RoundedBox(4, barX, y + 48, barWidth * (hunger / 100), barHeight, Color(200, 100, 0))
    
    -- Health Bar
    draw.SimpleText("Health: " .. math.floor(health) .. "%", "AJMRP_HUD_Text", barX, y + 50, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.RoundedBox(4, barX, y + 68, barWidth, barHeight, Color(50, 50, 50, 200))
    draw.RoundedBox(4, barX, y + 68, barWidth * (health / 100), barHeight, Color(200, 0, 0))
end)

concommand.Add("ajmrp_toggle_hud", function(ply)
    if hook.GetTable().HUDPaint.AJMRP_HUD then
        hook.Remove("HUDPaint", "AJMRP_HUD")
        LocalPlayer():ChatPrint("HUD disabled.")
    else
        hook.Add("HUDPaint", "AJMRP_HUD", function()
            if not IsValid(LocalPlayer()) then return end
            local ply = LocalPlayer()
            local credits = ply:GetCredits()
            local hunger = ply:GetHunger()
            local stamina = ply:GetStamina()
            local health = ply:Health()
            local name = ply:GetCharacterName() or ply:Nick()
            local job = AJMRP.Config.Jobs[ply:GetJob()] and AJMRP.Config.Jobs[ply:GetJob()].name or "Unknown"
            
            local x, y = ScrW() / 2 - 225, ScrH() - 90
            local width, height = 450, 90
            
            draw.RoundedBox(8, x, y, width, height, Color(50, 50, 50, 180))
            
            draw.SimpleText("Character: " .. name, "AJMRP_HUD_Title", x + 10, y + 10, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("Job: " .. job, "AJMRP_HUD_Text", x + 10, y + 30, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("Credits: " .. credits, "AJMRP_HUD_Text", x + 10, y + 50, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            local barWidth, barHeight = 100, 10
            local barX = x + 280
            
            draw.SimpleText("Stamina: " .. math.floor(stamina) .. "%", "AJMRP_HUD_Text", barX, y + 10, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.RoundedBox(4, barX, y + 28, barWidth, barHeight, Color(50, 50, 50, 200))
            draw.RoundedBox(4, barX, y + 28, barWidth * (stamina / 100), barHeight, Color(0, 200, 0))
            
            draw.SimpleText("Hunger: " .. math.floor(hunger) .. "%", "AJMRP_HUD_Text", barX, y + 30, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.RoundedBox(4, barX, y + 48, barWidth, barHeight, Color(50, 50, 50, 200))
            draw.RoundedBox(4, barX, y + 48, barWidth * (hunger / 100), barHeight, Color(200, 100, 0))
            
            draw.SimpleText("Health: " .. math.floor(health) .. "%", "AJMRP_HUD_Text", barX, y + 50, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.RoundedBox(4, barX, y + 68, barWidth, barHeight, Color(50, 50, 50, 200))
            draw.RoundedBox(4, barX, y + 68, barWidth * (health / 100), barHeight, Color(200, 0, 0))
        end)
        LocalPlayer():ChatPrint("HUD enabled.")
    end
end)