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

-- Open spawn menu on Q key press, close on release
hook.Add("PlayerBindPress", "AJMRP_OpenSpawnMenu", function(ply, bind, pressed)
    if bind == "+menu" then
        if pressed then
            gui.EnableScreenClicker(true) -- Show mouse cursor
            if g_SpawnMenu and not g_SpawnMenu:IsVisible() then
                g_SpawnMenu:Open() -- Open spawn menu
            end
        else
            gui.EnableScreenClicker(false) -- Hide mouse cursor
            if g_SpawnMenu and g_SpawnMenu:IsVisible() then
                g_SpawnMenu:Close() -- Close spawn menu
            end
        end
        return true -- Suppress default Q menu
    end
end)

print("[AJMRP] cl_init.lua loaded")