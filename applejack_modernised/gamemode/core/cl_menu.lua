local function CreateCharacterTab(frame)
    local charPanel = vgui.Create("DPanel", frame)
    charPanel:SetSize(frame:GetWide() - 20, frame:GetTall() - 20)
    charPanel:SetPos(10, 10)
    charPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
    end
    
    local name = vgui.Create("DLabel", charPanel)
    name:SetSize(200, 20)
    name:SetPos(10, 10)
    name:SetText("Name: " .. (LocalPlayer():GetCharacterName() or LocalPlayer():Nick()))
    name:SetFont("AJMRP_HUD_Text")
    name:SetTextColor(Color(255, 255, 255, 220))
    
    local job = vgui.Create("DLabel", charPanel)
    job:SetSize(200, 20)
    job:SetPos(10, 30)
    job:SetText("Job: " .. (AJMRP.Config.Jobs[LocalPlayer():GetJob()] and AJMRP.Config.Jobs[LocalPlayer():GetJob()].name or "Unknown"))
    job:SetFont("AJMRP_HUD_Text")
    job:SetTextColor(Color(255, 255, 255, 220))
    
    local stamina = vgui.Create("DLabel", charPanel)
    stamina:SetSize(200, 20)
    stamina:SetPos(10, 50)
    stamina:SetText("Stamina: " .. math.floor(LocalPlayer():GetStamina()) .. "%")
    stamina:SetFont("AJMRP_HUD_Text")
    stamina:SetTextColor(Color(255, 255, 255, 220))
    
    local hunger = vgui.Create("DLabel", charPanel)
    hunger:SetSize(200, 20)
    hunger:SetPos(10, 70)
    hunger:SetText("Hunger: " .. math.floor(LocalPlayer():GetHunger()) .. "%")
    hunger:SetFont("AJMRP_HUD_Text")
    hunger:SetTextColor(Color(255, 255, 255, 220))
    
    local health = vgui.Create("DLabel", charPanel)
    health:SetSize(200, 20)
    health:SetPos(10, 90)
    health:SetText("Health: " .. LocalPlayer():Health() .. "%")
    health:SetFont("AJMRP_HUD_Text")
    health:SetTextColor(Color(255, 255, 255, 220))
    
    return charPanel
end

local function CreateDoorsTab(frame)
    local doorsPanel = vgui.Create("DPanel", frame)
    doorsPanel:SetSize(frame:GetWide() - 20, frame:GetTall() - 20)
    doorsPanel:SetPos(10, 10)
    doorsPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
    end
    
    local list = vgui.Create("DListView", doorsPanel)
    list:SetSize(doorsPanel:GetWide() - 20, doorsPanel:GetTall() - 20)
    list:SetPos(10, 10)
    list:AddColumn("Door")
    list:AddColumn("Status")
    
    -- Populate with door data (placeholder)
    list:AddLine("Front Door", "Owned")
    list:AddLine("Back Door", "Unowned")
    
    return doorsPanel
end

local function CreateShopTab(frame)
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
    
    for id, item in pairs(AJMRP.Config.Items) do
        local allowed = false
        for _, job in ipairs(item.jobs) do
            if job == LocalPlayer():GetJob() then
                allowed = true
                break
            end
        end
        
        local itemPanel = layout:Add("DPanel")
        itemPanel:SetSize(150, 200)
        itemPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
        end
        
        local icon = vgui.Create("DImage", itemPanel)
        icon:SetSize(64, 64)
        icon:SetPos(43, 10)
        icon:SetImage(item.icon or "icon16/error.png")
        
        local name = vgui.Create("DLabel", itemPanel)
        name:SetSize(140, 20)
        name:SetPos(5, 80)
        name:SetText(item.name)
        name:SetFont("AJMRP_HUD_Text")
        name:SetTextColor(Color(255, 255, 255, 220))
        name:SetContentAlignment(5)
        
        local price = vgui.Create("DLabel", itemPanel)
        price:SetSize(140, 20)
        price:SetPos(5, 100)
        price:SetText("Price: " .. item.price .. " Credits")
        price:SetFont("AJMRP_HUD_Text")
        price:SetTextColor(Color(255, 255, 255, 220))
        price:SetContentAlignment(5)
        
        local weight = vgui.Create("DLabel", itemPanel)
        weight:SetSize(140, 20)
        weight:SetPos(5, 120)
        weight:SetText("Weight: " .. item.weight)
        weight:SetFont("AJMRP_HUD_Text")
        weight:SetTextColor(Color(255, 255, 255, 220))
        weight:SetContentAlignment(5)
        
        local buy = vgui.Create("DButton", itemPanel)
        buy:SetSize(100, 30)
        buy:SetPos(25, 150)
        buy:SetText("Buy")
        buy:SetFont("AJMRP_HUD_Text")
        buy:SetTextColor(Color(255, 255, 255, 220))
        buy.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(0, 120, 0, 200) or Color(0, 80, 0, 200))
        end
        buy:SetEnabled(allowed)
        buy.DoClick = function()
            net.Start("AJMRP_BuyItem")
            net.WriteString(id)
            net.SendToServer()
        end
    end
    
    return shopPanel
end

net.Receive("AJMRP_BuyItemResponse", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    LocalPlayer():ChatPrint(message)
end)

local function CreateF1Menu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
    end
    
    local tabs = vgui.Create("DPropertySheet", frame)
    tabs:SetSize(frame:GetWide() - 20, frame:GetTall() - 20)
    tabs:SetPos(10, 10)
    
    local characterTab = CreateCharacterTab(frame)
    tabs:AddSheet("Character", characterTab, "icon16/user.png")
    
    local shopTab = CreateShopTab(frame)
    tabs:AddSheet("Shop", shopTab, "icon16/cart.png")
    
    local doorsTab = CreateDoorsTab(frame)
    tabs:AddSheet("Doors", doorsTab, "icon16/door.png")
end

concommand.Add("ajmrp_menu", function()
    CreateF1Menu()
end)

hook.Add("ShowSpare1", "AJMRP_OpenMenu", function()
    CreateF1Menu()
end)