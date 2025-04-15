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

function GM:SpawnMenuEnabled()
    return true
end

function GM:SpawnMenuOpen()
    return true
end

-- Initialize spawn menu with safer checks and fallback
local function InitializeSpawnMenu()
    if not g_SpawnMenu then
        print("[AJMRP] Attempting to create g_SpawnMenu")
        -- Verify vgui module exists
        if not vgui or not vgui.Create then
            print("[AJMRP] ERROR: vgui module or vgui.Create is nil")
            if LocalPlayer() and IsValid(LocalPlayer()) then
                LocalPlayer():ChatPrint("VGUI system unavailable. Contact an admin.")
            end
            return nil
        end

        -- Attempt to create SpawnMenu
        local success, result = pcall(function()
            return vgui.Create("SpawnMenu")
        end)

        if success and IsValid(result) then
            g_SpawnMenu = result
            print("[AJMRP] g_SpawnMenu created successfully")
            -- Populate with sandbox tabs if possible
            if spawnmenu then
                spawnmenu.PopulateFromEngine()
                spawnmenu.PopulateFromGamemode()
                g_SpawnMenu:SetSkin(GAMEMODE.Config.DarkRPSkin or "Default")
            else
                print("[AJMRP] WARNING: spawnmenu module unavailable")
            end
        else
            print("[AJMRP] ERROR: Failed to create g_SpawnMenu - " .. (result or "Unknown error"))
            -- Create a fallback menu
            g_SpawnMenu = vgui.Create("DFrame")
            if IsValid(g_SpawnMenu) then
                g_SpawnMenu:SetSize(400, 300)
                g_SpawnMenu:Center()
                g_SpawnMenu:SetTitle("AJMRP Fallback Spawn Menu")
                g_SpawnMenu:MakePopup()
                g_SpawnMenu.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
                end

                local label = vgui.Create("DLabel", g_SpawnMenu)
                label:SetPos(20, 40)
                label:SetSize(360, 100)
                label:SetText("Spawn menu failed to load. You can still access the AJMRP menu with F2.\n\nAvailable entities: Food, Medkit, Money Printer (if allowed by job).")
                label:SetWrap(true)
                label:SetTextColor(Color(255, 255, 255))

                local closeButton = vgui.Create("DButton", g_SpawnMenu)
                closeButton:SetPos(150, 260)
                closeButton:SetSize(100, 30)
                closeButton:SetText("Close")
                closeButton.DoClick = function()
                    g_SpawnMenu:Close()
                end
            else
                print("[AJMRP] ERROR: Failed to create fallback menu")
            end
            if LocalPlayer() and IsValid(LocalPlayer()) then
                LocalPlayer():ChatPrint("Spawn menu unavailable. Using fallback menu.")
            end
        end
    end
    return g_SpawnMenu
end

-- Debug spawn menu initialization with delayed retry
hook.Add("InitPostEntity", "AJMRP_InitSpawnMenu", function()
    print("[AJMRP] InitPostEntity: Checking spawn menu")
    print("[AJMRP] Gamemode: " .. (gmod.GetGamemode() and gmod.GetGamemode().Name or "Unknown"))
    print("[AJMRP] BaseClass: " .. (gmod.GetGamemode() and gmod.GetGamemode().BaseClass and gmod.GetGamemode().BaseClass.Name or "None"))
    print("[AJMRP] spawnmenu module: " .. (spawnmenu and "exists" or "nil"))
    print("[AJMRP] vgui module: " .. (vgui and "exists" or "nil"))
    print("[AJMRP] vgui.Create: " .. (vgui and vgui.Create and "exists" or "nil"))

    -- Force sandbox initialization
    if gmod.GetGamemode().BaseClass then
        print("[AJMRP] Calling sandbox PostGamemodeLoaded")
        hook.Call("PostGamemodeLoaded", gmod.GetGamemode().BaseClass)
        -- Attempt to call sandbox's InitPostEntity if available
        if gmod.GetGamemode().BaseClass.InitPostEntity then
            local success, err = pcall(gmod.GetGamemode().BaseClass.InitPostEntity, gmod.GetGamemode().BaseClass)
            print("[AJMRP] Sandbox InitPostEntity: " .. (success and "Success" or "Failed - " .. tostring(err)))
        end
    end

    -- Retry initialization with increasing delays until successful
    local attempts = 0
    local maxAttempts = 5
    local function TryInitialize()
        attempts = attempts + 1
        if not g_SpawnMenu and attempts <= maxAttempts then
            print("[AJMRP] Attempt " .. attempts .. ": g_SpawnMenu is nil, initializing")
            InitializeSpawnMenu()
            if g_SpawnMenu then
                print("[AJMRP] g_SpawnMenu initialized on attempt " .. attempts)
            else
                print("[AJMRP] g_SpawnMenu still nil, scheduling retry")
                timer.Simple(3, TryInitialize) -- Increased delay to 3 seconds
            end
        elseif attempts > maxAttempts then
            print("[AJMRP] ERROR: Failed to initialize g_SpawnMenu after " .. maxAttempts .. " attempts")
            if LocalPlayer() and IsValid(LocalPlayer()) then
                LocalPlayer():ChatPrint("Spawn menu failed to load after multiple attempts. Use F2 for the AJMRP menu.")
            end
        else
            print("[AJMRP] g_SpawnMenu already exists")
        end
    end

    -- Start the first attempt after a short delay
    timer.Simple(2, TryInitialize)
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
                    if LocalPlayer() and IsValid(LocalPlayer()) then
                        LocalPlayer():ChatPrint("Failed to open spawn menu. Using fallback menu...")
                    end
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

-- Diagnostic console command to test VGUI
concommand.Add("ajmrp_test_vgui", function()
    print("[AJMRP] Testing VGUI...")
    print("vgui exists: " .. tostring(!!vgui))
    print("vgui.Create exists: " .. tostring(!!(vgui and vgui.Create)))
    print("spawnmenu exists: " .. tostring(!!spawnmenu))
    local success, result = pcall(function()
        local testPanel = vgui.Create("SpawnMenu")
        if IsValid(testPanel) then
            testPanel:Remove()
            return "SpawnMenu creation succeeded"
        else
            return "SpawnMenu creation failed"
        end
    end)
    print("SpawnMenu test: " .. (success and result or "Failed - " .. tostring(result)))
end)

print("[AJMRP] cl_init.lua loaded")