-- Ensure AJMRP table exists
AJMRP = AJMRP or {}

-- Character Tab: Displays name, job, credits, and job XP
local function CreateCharacterTab(frame)
    if not IsValid(LocalPlayer()) then
        print("[AJMRP] CreateCharacterTab: LocalPlayer not valid")
        return
    end
    if not AJMRP.Config then
        print("[AJMRP] CreateCharacterTab: AJMRP.Config not loaded")
        return
    end

    local charPanel = vgui.Create("DPanel", frame)
    charPanel:SetSize(frame:GetWide() - 20, frame:GetTall() - 20)
    charPanel:SetPos(10, 10)
    charPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
    end

    -- Player Name
    local nameLabel = vgui.Create("DLabel", charPanel)
    nameLabel:SetSize(300, 20)
    nameLabel:SetPos(10, 10)
    nameLabel:SetText("Name: " .. (LocalPlayer():GetCharacterName() or LocalPlayer():Nick()))
    nameLabel:SetFont("DermaDefault")
    nameLabel:SetTextColor(Color(255, 255, 255, 220))

    -- Current Job
    local jobLabel = vgui.Create("DLabel", charPanel)
    jobLabel:SetSize(300, 20)
    jobLabel:SetPos(10, 40)
    local job = LocalPlayer():GetJob() or "citizen"
    local jobName = (AJMRP.Config.Jobs[job] and AJMRP.Config.Jobs[job].name) or "Unknown"
    jobLabel:SetText("Job: " .. jobName)
    jobLabel:SetFont("DermaDefault")
    jobLabel:SetTextColor(Color(255, 255, 255, 220))

    -- Credits
    local creditsLabel = vgui.Create("DLabel", charPanel)
    creditsLabel:SetSize(300, 20)
    creditsLabel:SetPos(10, 70)
    creditsLabel:SetText("Credits: " .. (LocalPlayer():GetCredits() or 0))
    creditsLabel:SetFont("DermaDefault")
    creditsLabel:SetTextColor(Color(255, 255, 255, 220))

    -- Job XP
    local xpLabel = vgui.Create("DLabel", charPanel)
    xpLabel:SetSize(300, 20)
    xpLabel:SetPos(10, 100)
    xpLabel:SetText("Job XP: " .. (LocalPlayer():GetJobXP() or 0))
    xpLabel:SetFont("DermaDefault")
    xpLabel:SetTextColor(Color(255, 255, 255, 220))

    return charPanel
end

-- Shop Tab: Lists items with name, description, price, weight, and buy button
local function CreateShopTab(frame)
    if not IsValid(LocalPlayer()) then
        print("[AJMRP] CreateShopTab: LocalPlayer not valid")
        return
    end
    if not AJMRP.Config then
        print("[AJMRP] CreateShopTab: AJMRP.Config not loaded")
        return
    end

    local shopPanel = vgui.Create("DPanel", frame)
    shopPanel:SetSize(frame:GetWide() - 20, frame:GetTall() - 20)
    shopPanel:SetPos(10, 10)
    shopPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
    end

    local scroll = vgui.Create("DScrollPanel", shopPanel)
    scroll:SetSize(shopPanel:GetWide() - 20, shopPanel:GetTall() - 20)
    scroll:SetPos(10, 10)

    local layout = vgui.Create("DIconLayout", scroll)
    layout:SetSize(scroll:GetWide(), scroll:GetTall())
    layout:SetPos(0, 0)
    layout:SetSpaceX(10)
    layout:SetSpaceY(10)

    for id, item in pairs(AJMRP.Config.Items or {}) do
        local allowed = false
        for _, job in ipairs(item.jobs or {}) do
            if job == (LocalPlayer():GetJob() or "citizen") then
                allowed = true
                break
            end
        end

        local itemPanel = layout:Add("DPanel")
        itemPanel:SetSize(200, 250)
        itemPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
        end

        -- Item Name
        local nameLabel = vgui.Create("DLabel", itemPanel)
        nameLabel:SetSize(180, 20)
        nameLabel:SetPos(10, 10)
        nameLabel:SetText(item.name or "Unknown Item")
        nameLabel:SetFont("DermaDefault")
        nameLabel:SetTextColor(Color(255, 255, 255, 220))
        nameLabel:SetContentAlignment(5)

        -- Description
        local descLabel = vgui.Create("DLabel", itemPanel)
        descLabel:SetSize(180, 60)
        descLabel:SetPos(10, 40)
        descLabel:SetText(item.description or "A useful item for your roleplay adventures.")
        descLabel:SetFont("DermaDefault")
        descLabel:SetTextColor(Color(255, 255, 255, 220))
        descLabel:SetWrap(true)
        descLabel:SetContentAlignment(5)

        -- Price
        local priceLabel = vgui.Create("DLabel", itemPanel)
        priceLabel:SetSize(180, 20)
        priceLabel:SetPos(10, 110)
        priceLabel:SetText("Price: " .. (item.price or 0) .. " Credits")
        priceLabel:SetFont("DermaDefault")
        priceLabel:SetTextColor(Color(255, 255, 255, 220))
        priceLabel:SetContentAlignment(5)

        -- Weight
        local weightLabel = vgui.Create("DLabel", itemPanel)
        weightLabel:SetSize(180, 20)
        weightLabel:SetPos(10, 140)
        weightLabel:SetText("Weight: " .. (item.weight or 0))
        weightLabel:SetFont("DermaDefault")
        weightLabel:SetTextColor(Color(255, 255, 255, 220))
        weightLabel:SetContentAlignment(5)

        -- Buy Button
        local buyButton = vgui.Create("DButton", itemPanel)
        buyButton:SetSize(100, 30)
        buyButton:SetPos(50, 200)
        buyButton:SetText("Buy")
        buyButton:SetFont("DermaDefault")
        buyButton:SetTextColor(Color(255, 255, 255, 220))
        buyButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(0, 120, 0, 200) or Color(0, 80, 0, 200))
        end
        buyButton:SetEnabled(allowed)
        buyButton.DoClick = function()
            net.Start("AJMRP_BuyItem")
            net.WriteString(id)
            net.SendToServer()
        end
    end

    return shopPanel
end

-- Handle buy item response from server
net.Receive("AJMRP_BuyItemResponse", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    if IsValid(LocalPlayer()) then
        LocalPlayer():ChatPrint(message)
    else
        print("[AJMRP] BuyItemResponse: LocalPlayer not valid")
    end
end)

-- Main menu creation function
local function CreateMainMenu()
    if not IsValid(LocalPlayer()) then
        print("[AJMRP] CreateMainMenu: LocalPlayer not valid")
        return
    end

    local success, err = pcall(function()
        local frame = vgui.Create("DFrame")
        frame:SetSize(800, 600)
        frame:Center()
        frame:SetTitle("AJMRP Menu")
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)
        frame:MakePopup()
        frame.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
        end

        local tabs = vgui.Create("DPropertySheet", frame)
        tabs:SetSize(frame:GetWide() - 20, frame:GetTall() - 20)
        tabs:SetPos(10, 10)

        -- Character Tab
        local characterTab = CreateCharacterTab(frame)
        if characterTab then
            tabs:AddSheet("Character", characterTab, "icon16/user.png")
        else
            print("[AJMRP] Failed to create Character tab")
        end

        -- Shop Tab
        local shopTab = CreateShopTab(frame)
        if shopTab then
            tabs:AddSheet("Shop", shopTab, "icon16/cart.png")
        else
            print("[AJMRP] Failed to create Shop tab")
        end
    end)

    if not success then
        print("[AJMRP] Error creating menu: " .. tostring(err))
    else
        print("[AJMRP] Menu opened successfully")
    end
end

-- Console command to open the menu manually
concommand.Add("ajmrp_menu", function()
    print("[AJMRP] Opening menu via console command")
    CreateMainMenu()
end)

-- Bind to F2 using ShowSpare1 (default F2 key binding should be gm_showspare1)
hook.Add("ShowSpare1", "AJMRP_OpenMenu", function()
    print("[AJMRP] ShowSpare1 hook triggered (F2 pressed)")
    CreateMainMenu()
end)

-- Command to rebind F2 to gm_showspare1 if needed
concommand.Add("ajmrp_bind_f2", function()
    if not IsValid(LocalPlayer()) then
        print("[AJMRP] Cannot bind F2: LocalPlayer not valid")
        return
    end
    LocalPlayer():ConCommand("bind f2 gm_showspare1")
    print("[AJMRP] F2 key bound to gm_showspare1. Press F2 to open the menu.")
end)

-- Notify player on spawn
hook.Add("InitPostEntity", "AJMRP_NotifyMenuKey", function()
    if not IsValid(LocalPlayer()) then return end
    LocalPlayer():ChatPrint("Press F2 to open the AJMRP menu! If F2 doesn't work, type 'ajmrp_bind_f2' in the console to rebind it.")
end)

print("[AJMRP] cl_menu.lua loaded successfully")
