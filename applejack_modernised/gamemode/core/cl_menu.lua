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

-- Jobs Tab: Lists all available jobs in a vertical list with title, description, salary, and switch button
local function CreateJobsTab(frame)
    if not IsValid(LocalPlayer()) then
        print("[AJMRP] CreateJobsTab: LocalPlayer not valid")
        return
    end
    if not AJMRP.Config then
        print("[AJMRP] CreateJobsTab: AJMRP.Config not loaded")
        return
    end

    local jobsPanel = vgui.Create("DPanel", frame)
    jobsPanel:SetSize(frame:GetWide() - 20, frame:GetTall() - 20)
    jobsPanel:SetPos(10, 10)
    jobsPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
    end

    local scroll = vgui.Create("DScrollPanel", jobsPanel)
    scroll:SetSize(jobsPanel:GetWide() - 20, jobsPanel:GetTall() - 20)
    scroll:SetPos(10, 10)

    local yPos = 0
    for jobID, jobData in pairs(AJMRP.Config.Jobs or {}) do
        local jobPanel = vgui.Create("DPanel", scroll)
        jobPanel:SetSize(scroll:GetWide() - 20, 120) -- Increased height for more content
        jobPanel:SetPos(0, yPos)
        jobPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
        end

        -- Job Title
        local nameLabel = vgui.Create("DLabel", jobPanel)
        nameLabel:SetSize(300, 20)
        nameLabel:SetPos(10, 10)
        nameLabel:SetText(jobData.name or "Unknown Job")
        nameLabel:SetFont("DermaDefault")
        nameLabel:SetTextColor(Color(255, 255, 255, 220))

        -- Description
        local descLabel = vgui.Create("DLabel", jobPanel)
        descLabel:SetSize(300, 40)
        descLabel:SetPos(10, 30)
        descLabel:SetText(jobData.description or "A role in the city with specific duties.")
        descLabel:SetFont("DermaDefault")
        descLabel:SetTextColor(Color(255, 255, 255, 220))
        descLabel:SetWrap(true)

        -- Salary
        local salaryLabel = vgui.Create("DLabel", jobPanel)
        salaryLabel:SetSize(300, 20)
        salaryLabel:SetPos(10, 70)
        salaryLabel:SetText("Salary: " .. (jobData.salary or 100) .. " Credits")
        salaryLabel:SetFont("DermaDefault")
        salaryLabel:SetTextColor(Color(255, 255, 255, 220))

        -- Switch Job Button
        local switchButton = vgui.Create("DButton", jobPanel)
        switchButton:SetSize(100, 30)
        switchButton:SetPos(jobPanel:GetWide() - 110, 80)
        switchButton:SetText("Switch Job")
        switchButton:SetFont("DermaDefault")
        switchButton:SetTextColor(Color(255, 255, 255, 220))
        switchButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(0, 120, 0, 200) or Color(0, 80, 0, 200))
        end
        switchButton.DoClick = function()
            net.Start("AJMRP_SwitchJob")
            net.WriteString(jobID)
            net.SendToServer()
        end

        yPos = yPos + 130 -- Space between entries
    end

    return jobsPanel
end

-- Shop Tab: Lists items in a vertical list with name, description, price, weight, and buy button
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

    local yPos = 0
    for id, item in pairs(AJMRP.Config.Items or {}) do
        local allowed = false
        for _, job in ipairs(item.jobs or {}) do
            if job == (LocalPlayer():GetJob() or "citizen") then
                allowed = true
                break
            end
        end

        local itemPanel = vgui.Create("DPanel", scroll)
        itemPanel:SetSize(scroll:GetWide() - 20, 150)
        itemPanel:SetPos(0, yPos)
        itemPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
        end

        -- Item Name
        local nameLabel = vgui.Create("DLabel", itemPanel)
        nameLabel:SetSize(300, 20)
        nameLabel:SetPos(10, 10)
        nameLabel:SetText(item.name or "Unknown Item")
        nameLabel:SetFont("DermaDefault")
        nameLabel:SetTextColor(Color(255, 255, 255, 220))

        -- Description
        local descLabel = vgui.Create("DLabel", itemPanel)
        descLabel:SetSize(300, 40)
        descLabel:SetPos(10, 30)
        descLabel:SetText(item.description or "A useful item for your roleplay adventures.")
        descLabel:SetFont("DermaDefault")
        descLabel:SetTextColor(Color(255, 255, 255, 220))
        descLabel:SetWrap(true)

        -- Price
        local priceLabel = vgui.Create("DLabel", itemPanel)
        priceLabel:SetSize(300, 20)
        priceLabel:SetPos(10, 70)
        priceLabel:SetText("Price: " .. (item.price or 0) .. " Credits")
        priceLabel:SetFont("DermaDefault")
        priceLabel:SetTextColor(Color(255, 255, 255, 220))

        -- Weight
        local weightLabel = vgui.Create("DLabel", itemPanel)
        weightLabel:SetSize(300, 20)
        weightLabel:SetPos(10, 90)
        weightLabel:SetText("Weight: " .. (item.weight or 0))
        weightLabel:SetFont("DermaDefault")
        weightLabel:SetTextColor(Color(255, 255, 255, 220))

        -- Buy Button
        local buyButton = vgui.Create("DButton", itemPanel)
        buyButton:SetSize(100, 30)
        buyButton:SetPos(itemPanel:GetWide() - 110, 110)
        buyButton:SetText("Buy")
        buyButton:SetFont("DermaDefault")
        buyButton:SetTextColor(Color(255, 255, 255, 220))
        buyButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(0, 120, 0, 200) or Color(0, 80, 0, 200))
        end
        buyButton:SetEnabled(allowed)
        buyButton.DoClick = function()
            print("[AJMRP] Sending AJMRP_BuyItem for item: " .. id)
            net.Start("AJMRP_BuyItem")
            net.WriteString(id)
            net.SendToServer()
        end

        yPos = yPos + 160 -- Space between entries
    end

    return shopPanel
end

-- Inventory Tab: Grid-based inventory with drag-and-drop, stacking, and limits
local function CreateInventoryTab(frame)
    if not IsValid(LocalPlayer()) then
        print("[AJMRP] CreateInventoryTab: LocalPlayer not valid")
        return
    end
    if not AJMRP.Config then
        print("[AJMRP] CreateInventoryTab: AJMRP.Config not loaded")
        return
    end

    local inventoryPanel = vgui.Create("DPanel", frame)
    inventoryPanel:SetSize(frame:GetWide() - 20, frame:GetTall() - 20)
    inventoryPanel:SetPos(10, 10)
    inventoryPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 220))
    end

    -- Inventory limits
    local maxSlots = 25 -- 5x5 grid
    local maxWeight = 50 -- Total weight limit

    -- Calculate current weight
    local inventory = LocalPlayer():GetInventory()
    local currentWeight = 0
    local slotCount = 0
    for itemID, quantity in pairs(inventory) do
        local item = AJMRP.Config.Items[itemID]
        if item then
            currentWeight = currentWeight + (item.weight * quantity)
            slotCount = slotCount + 1 -- Each stack takes one slot
        end
    end

    -- Weight and slot info
    local weightLabel = vgui.Create("DLabel", inventoryPanel)
    weightLabel:SetSize(200, 20)
    weightLabel:SetPos(10, 10)
    weightLabel:SetText("Weight: " .. currentWeight .. "/" .. maxWeight)
    weightLabel:SetFont("DermaDefault")
    weightLabel:SetTextColor(Color(255, 255, 255, 220))

    local slotsLabel = vgui.Create("DLabel", inventoryPanel)
    slotsLabel:SetSize(200, 20)
    slotsLabel:SetPos(220, 10)
    slotsLabel:SetText("Slots: " .. slotCount .. "/" .. maxSlots)
    weightLabel:SetFont("DermaDefault")
    weightLabel:SetTextColor(Color(255, 255, 255, 220))

    -- Grid for inventory items using DIconLayout
    local gridPanel = vgui.Create("DPanel", inventoryPanel)
    gridPanel:SetSize(500, 500)
    gridPanel:SetPos(10, 40)
    gridPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
    end

    local layout = vgui.Create("DIconLayout", gridPanel)
    layout:SetSize(470, 470) -- Slightly smaller to fit inside gridPanel with padding
    layout:SetPos(15, 15)
    layout:SetSpaceX(10)
    layout:SetSpaceY(10)
    layout:MakeDroppable("AJMRP_Inventory") -- Enable drag-and-drop

    -- Inventory slots (stored as a list for drag-and-drop)
    local slots = {}
    local slotItems = {} -- { slotIndex = { itemID, quantity } }

    -- Populate the grid with slots
    for i = 1, maxSlots do
        local slot = vgui.Create("DPanel")
        slot:SetSize(80, 80)
        slot.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
        end
        slot.slotIndex = i
        slots[i] = slot
        layout:Add(slot)

        -- Allow dropping on the slot
        slot.OnDrop = function(self, draggedPanel)
            local draggedSlotIndex = draggedPanel.slotIndex
            local targetSlotIndex = self.slotIndex

            -- If target slot is empty, move the item
            if not slotItems[targetSlotIndex] then
                slotItems[targetSlotIndex] = slotItems[draggedSlotIndex]
                slotItems[draggedSlotIndex] = nil
            -- If target slot has the same item, stack them
            elseif slotItems[targetSlotIndex].itemID == slotItems[draggedSlotIndex].itemID then
                slotItems[targetSlotIndex].quantity = slotItems[targetSlotIndex].quantity + slotItems[draggedSlotIndex].quantity
                slotItems[draggedSlotIndex] = nil
            -- Otherwise, swap the items
            else
                local temp = slotItems[targetSlotIndex]
                slotItems[targetSlotIndex] = slotItems[draggedSlotIndex]
                slotItems[draggedSlotIndex] = temp
            end

            -- Update the UI
            for idx, itemSlot in pairs(slots) do
                itemSlot:Clear()
                if slotItems[idx] then
                    local item = AJMRP.Config.Items[slotItems[idx].itemID]
                    if item then
                        local itemIcon = vgui.Create("DImageButton", itemSlot)
                        itemIcon:SetSize(64, 64)
                        itemIcon:SetPos(8, 8)
                        itemIcon:SetImage(item.icon or "icon16/error.png")
                        itemIcon:SetTooltip(item.name .. " x" .. slotItems[idx].quantity)

                        local quantityLabel = vgui.Create("DLabel", itemSlot)
                        quantityLabel:SetSize(80, 20)
                        quantityLabel:SetPos(0, 60)
                        quantityLabel:SetText("x" .. slotItems[idx].quantity)
                        quantityLabel:SetFont("DermaDefault")
                        quantityLabel:SetTextColor(Color(255, 255, 255, 220))
                        quantityLabel:SetContentAlignment(5)

                        itemIcon.slotIndex = idx
                        itemIcon.DoClick = function() end -- Prevent clicking for now
                        itemIcon.OnMousePressed = function(self, code)
                            if code == MOUSE_LEFT then
                                self:MouseCapture(true)
                                self:DragMousePress(code)
                            end
                        end
                        itemIcon.OnMouseReleased = function(self, code)
                            if code == MOUSE_LEFT then
                                self:MouseCapture(false)
                                self:DragMouseRelease(code)
                            end
                        end
                    end
                end
            end

            -- Update the player's inventory on the server
            local newInventory = {}
            for idx, slotData in pairs(slotItems) do
                if slotData then
                    newInventory[slotData.itemID] = slotData.quantity
                end
            end
            net.Start("AJMRP_UpdateInventory")
            net.WriteTable(newInventory)
            net.SendToServer()
        end
    end

    -- Populate the grid with items from the player's inventory
    local slotIndex = 1
    for itemID, quantity in pairs(inventory) do
        if slotIndex > maxSlots then break end
        slotItems[slotIndex] = { itemID = itemID, quantity = quantity }
        slotIndex = slotIndex + 1
    end

    -- Add items to the grid
    for idx, slot in pairs(slots) do
        if slotItems[idx] then
            local item = AJMRP.Config.Items[slotItems[idx].itemID]
            if item then
                local itemIcon = vgui.Create("DImageButton", slot)
                itemIcon:SetSize(64, 64)
                itemIcon:SetPos(8, 8)
                itemIcon:SetImage(item.icon or "icon16/error.png")
                itemIcon:SetTooltip(item.name .. " x" .. slotItems[idx].quantity)

                local quantityLabel = vgui.Create("DLabel", slot)
                quantityLabel:SetSize(80, 20)
                quantityLabel:SetPos(0, 60)
                quantityLabel:SetText("x" .. slotItems[idx].quantity)
                quantityLabel:SetFont("DermaDefault")
                quantityLabel:SetTextColor(Color(255, 255, 255, 220))
                quantityLabel:SetContentAlignment(5)

                itemIcon.slotIndex = idx
                itemIcon.DoClick = function() end -- Prevent clicking for now
                itemIcon.OnMousePressed = function(self, code)
                    if code == MOUSE_LEFT then
                        self:MouseCapture(true)
                        self:DragMousePress(code)
                    end
                end
                itemIcon.OnMouseReleased = function(self, code)
                    if code == MOUSE_LEFT then
                        self:MouseCapture(false)
                        self:DragMouseRelease(code)
                    end
                end
            end
        end
    end

    return inventoryPanel
end

-- Handle buy item response from server
net.Receive("AJMRP_BuyItemResponse", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    print("[AJMRP] Received AJMRP_BuyItemResponse: " .. tostring(success) .. " - " .. message)
    chat.AddText(Color(255, 255, 255), "[Shop] ", Color(200, 200, 200), message)
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
        tabs:SetSize(frame:GetWide() - 20, frame:GetTall() - 50) -- Adjusted height to account for new position
        tabs:SetPos(10, 30) -- Moved down to avoid overlapping the title

        -- Character Tab
        local characterTab = CreateCharacterTab(frame)
        if characterTab then
            tabs:AddSheet("Character", characterTab, "icon16/user.png")
        else
            print("[AJMRP] Failed to create Character tab")
        end

        -- Jobs Tab (moved before Shop tab)
        local jobsTab = CreateJobsTab(frame)
        if jobsTab then
            tabs:AddSheet("Jobs", jobsTab, "icon16/briefcase.png")
        else
            print("[AJMRP] Failed to create Jobs tab")
        end

        -- Shop Tab
        local shopTab = CreateShopTab(frame)
        if shopTab then
            tabs:AddSheet("Shop", shopTab, "icon16/cart.png")
        else
            print("[AJMRP] Failed to create Shop tab")
        end

        -- Inventory Tab
        local inventoryTab = CreateInventoryTab(frame)
        if inventoryTab then
            tabs:AddSheet("Inventory", inventoryTab, "icon16/box.png")
        else
            print("[AJMRP] Failed to create Inventory tab")
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

-- Detect F2 key press directly using PlayerBindPress
hook.Add("PlayerBindPress", "AJMRP_OpenMenuOnF2", function(ply, bind, pressed)
    if bind == "gm_showteam" and pressed then -- F2 is bound to gm_showteam
        print("[AJMRP] Detected F2 press via PlayerBindPress")
        LocalPlayer():ChatPrint("F2 pressed! Opening menu...")
        CreateMainMenu()
        return true -- Suppress the default gm_showteam behavior
    end
end)

-- Notify player on spawn
hook.Add("InitPostEntity", "AJMRP_NotifyMenuKey", function()
    if not IsValid(LocalPlayer()) then return end
    LocalPlayer():ChatPrint("Press F2 to open the AJMRP menu!")
end)

print("[AJMRP] cl_menu.lua loaded successfully")