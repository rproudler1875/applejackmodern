print("[AJMRP] Loading cl_init.lua")

include("shared.lua")
include("core/sh_config.lua")
include("core/sh_character.lua")
include("core/sh_door_ownership.lua")
include("core/sh_hunger.lua")
include("core/sh_stamina.lua")
include("core/sh_jobs.lua")
include("core/sh_economy.lua")
include("core/cl_hud.lua")
include("core/cl_menu.lua")

function GM:HUDShouldDraw(name)
    if name == "CHudHealth" or name == "CHudBattery" then
        return false
    end
    return true
end

hook.Add("HUDPaint", "AJMRP_HideHUDInMenu", function()
    if IsValid(AJMRP.MenuPanel) and IsValid(AJMRP.HUDPanel) then
        print("[AJMRP] Menu open, hiding HUD")
        AJMRP.HUDPanel.isVisible = false
    elseif IsValid(AJMRP.HUDPanel) then
        print("[AJMRP] Menu closed, showing HUD")
        AJMRP.HUDPanel.isVisible = true
    end
end)

print("[AJMRP] cl_init.lua loaded")