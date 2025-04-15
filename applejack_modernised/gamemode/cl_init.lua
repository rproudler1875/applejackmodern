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

-- Ensure spawn menu is enabled
function GM:SpawnMenuEnabled()
    return true
end

-- Allow all players to open the spawn menu
function GM:SpawnMenuOpen()
    return true
end

-- Initialize spawn menu
local function InitializeSpawnMenu()
    if not g_SpawnMenu then
        print("[AJMRP] Attempting to create g_SpawnMenu")
        -- Check if SpawnMenu VGUI is registered
        if vgui.GetControlList() and vgui.GetControlList()["SpawnMenu"] then
            g_SpawnMenu = vgui.Create("SpawnMenu")
            if IsValid(g_SpawnMenu) then
                print("[AJMRP] g_SpawnMenu created successfully")
                -- Populate with sandbox tabs
                if spawnmenu then
                    spawnmenu.PopulateFromEngine()
                    spawnmenu.PopulateFromGamemode()
                    g_SpawnMenu:SetSkin(GAMEMODE.Config.DarkRPSkin or "Default")
                else
                    print("[AJMRP] WARNING: spawnmenu module unavailable")
                end
            else
                print("[AJMRP] ERROR: Failed to create g_SpawnMenu")
            end
        else
            print("[AJMRP] ERROR: SpawnMenu VGUI not registered")
        end
    end
    return g_SpawnMenu
end

-- Debug spawn menu initialization
hook.Add("InitPostEntity", "AJMRP_InitSpawnMenu", function()
    print("[AJMRP] InitPostEntity: Checking spawn menu")
    print("[AJMRP] Gamemode: " .. (gmod.GetGamemode() and gmod.GetGamemode().Name or "Unknown"))
    print("[AJMRP] BaseClass: " .. (gmod.GetGamemode() and gmod.GetGamemode().BaseClass and gmod.GetGamemode().BaseClass.Name or "None"))
    if spawnmenu then
        print("[AJMRP] spawnmenu module exists")
    else
        print("[AJMRP] spawnmenu module is nil")
    end
    if vgui.GetControlList() and vgui.GetControlList()["SpawnMenu"] then
        print("[AJMRP] SpawnMenu VGUI is registered")
    else
        print("[AJMRP] SpawnMenu VGUI is not registered")
    end
    -- Force sandbox initialization
    if gmod.GetGamemode().BaseClass then
        print("[AJMRP] Calling sandbox PostGamemodeLoaded")
        hook.Call("PostGamemodeLoaded", gmod.GetGamemode().BaseClass)
    end
    -- Delay initialization to ensure VGUI registration
    timer.Simple(2, function()
        if not g_SpawnMenu then
            print("[AJMRP] g_SpawnMenu is nil, initializing")
            InitializeSpawnMenu()
            if g_SpawnMenu then
                print("[AJMRP] g_SpawnMenu initialized in delayed hook")
            else
                print("[AJMRP] ERROR: g_SpawnMenu still nil after delay")
            end
        else
            print("[AJMRP] g_SpawnMenu already exists")
        end
    end)
end)

-- Open spawn menu on Q key press, close on release
hook.Add("PlayerBindPress", "AJMRP_OpenSpawnMenu", function(ply, bind, pressed)
    if bind == "+menu" then
        print("[AJMRP] PlayerBindPress: +menu, pressed = " .. tostring(pressed))
        if pressed then
            gui.EnableScreenClicker(true) -- Show mouse cursor
            if not g_SpawnMenu then
                print("[AJMRP] g_SpawnMenu is nil, initializing")
                InitializeSpawnMenu()
                if g_SpawnMenu then
                    print("[AJMRP] g_SpawnMenu initialized, opening")
                    g_SpawnMenu:Open()
                else
                    print("[AJMRP] ERROR: g_SpawnMenu still nil")
                    LocalPlayer():ChatPrint("Failed to open spawn menu. Admins: Run 'lua_run_cl if vgui.GetControlList()[\"SpawnMenu\"] then vgui.Create(\"SpawnMenu\"):Open() else print(\"SpawnMenu not registered\") end' in console.")
                end
            else
                print("[AJMRP] Opening g_SpawnMenu")
                g_SpawnMenu:Open()
            end
        else
            gui.EnableScreenClicker(false) -- Hide mouse cursor
            if g_SpawnMenu and g_SpawnMenu:IsVisible() then
                print("[AJMRP] Closing g_SpawnMenu")
                g_SpawnMenu:Close()
            end
        end
        return true -- Suppress default context menu
    end
end)

print("[AJMRP] cl_init.lua loaded")