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

-- Debug spawn menu initialization
hook.Add("PostGamemodeLoaded", "AJMRP_InitSpawnMenu", function()
    print("[AJMRP] PostGamemodeLoaded: Checking spawn menu")
    if g_SpawnMenu then
        print("[AJMRP] g_SpawnMenu exists")
    else
        print("[AJMRP] g_SpawnMenu is nil")
    end
    if g_ContextMenu then
        print("[AJMRP] g_ContextMenu exists")
    else
        print("[AJMRP] g_ContextMenu is nil")
    end
end)

-- Open spawn menu on Q key press, close on release
hook.Add("PlayerBindPress", "AJMRP_OpenSpawnMenu", function(ply, bind, pressed)
    if bind == "+menu" then
        print("[AJMRP] PlayerBindPress: +menu, pressed = " .. tostring(pressed))
        if pressed then
            gui.EnableScreenClicker(true) -- Show mouse cursor
            if not g_SpawnMenu then
                print("[AJMRP] g_SpawnMenu is nil, initializing")
                CreateSpawnMenu() -- Create spawn menu if not initialized
            end
            if g_SpawnMenu then
                print("[AJMRP] Opening g_SpawnMenu")
                g_SpawnMenu:Open()
            else
                print("[AJMRP] Fallback: Opening g_ContextMenu")
                if g_ContextMenu then
                    g_ContextMenu:Open()
                else
                    print("[AJMRP] ERROR: Both g_SpawnMenu and g_ContextMenu are nil")
                end
            end
        else
            gui.EnableScreenClicker(false) -- Hide mouse cursor
            if g_SpawnMenu and g_SpawnMenu:IsVisible() then
                print("[AJMRP] Closing g_SpawnMenu")
                g_SpawnMenu:Close()
            elseif g_ContextMenu and g_ContextMenu:IsVisible() then
                print("[AJMRP] Closing g_ContextMenu")
                g_ContextMenu:Close()
            end
        end
        return true -- Suppress default context menu
    end
end)

print("[AJMRP] cl_init.lua loaded")
