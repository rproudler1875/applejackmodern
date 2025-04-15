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

-- Ensure spawn menu is initialized
hook.Add("PostGamemodeLoaded", "AJMRP_InitSpawnMenu", function()
    print("[AJMRP] PostGamemodeLoaded: Checking g_SpawnMenu")
    if g_SpawnMenu then
        print("[AJMRP] g_SpawnMenu is available")
    else
        print("[AJMRP] WARNING: g_SpawnMenu is nil")
    end
end)

-- Open spawn menu on Q key press, close on release
hook.Add("PlayerBindPress", "AJMRP_OpenSpawnMenu", function(ply, bind, pressed)
    if bind == "+menu" then
        print("[AJMRP] PlayerBindPress: +menu, pressed = " .. tostring(pressed))
        if pressed then
            gui.EnableScreenClicker(true) -- Show mouse cursor
            if g_SpawnMenu then
                print("[AJMRP] Opening spawn menu")
                g_SpawnMenu:Open()
            else
                print("[AJMRP] g_SpawnMenu is nil, trying spawnmenu.Activate()")
                spawnmenu.Activate()
            end
        else
            gui.EnableScreenClicker(false) -- Hide mouse cursor
            if g_SpawnMenu then
                print("[AJMRP] Closing spawn menu")
                g_SpawnMenu:Close()
            end
        end
        return true -- Suppress default Q menu
    end
end)

print("[AJMRP] cl_init.lua loaded")
