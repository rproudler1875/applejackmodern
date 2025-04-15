-- Define PLAYER meta table
local PLAYER = FindMetaTable("Player")

-- Available playermodels (curated for RP immersion)
AJMRP.Playermodels = {
    {name = "Male Citizen 1", model = "models/player/Group01/male_01.mdl"},
    {name = "Male Citizen 2", model = "models/player/Group01/male_02.mdl"},
    {name = "Female Citizen 1", model = "models/player/Group01/female_01.mdl"},
    {name = "Female Citizen 2", model = "models/player/Group01/female_02.mdl"}
    -- Add more as needed (e.g., HL2 rebels, custom models)
}

-- List of blocked words (case-insensitive)
local blockedWords = {"fuck", "shit", "damn", "ass", "bitch"} -- Extend as needed

-- Validate name input
local function IsValidName(name)
    name = string.Trim(name)
    if name == "" or string.len(name) < 3 or string.len(name) > 32 then
        return false, "Name must be 3-32 characters."
    end
    
    for _, word in ipairs(blockedWords) do
        if string.find(string.lower(name), word, 1, true) then
            return false, "Name contains inappropriate words."
        end
    end
    
    return true
end

if SERVER then
    -- Load character data
    function PLAYER:LoadCharacter()
        local steamID = self:SteamID64()
        local path = "applejack_modernised/characters/" .. steamID .. ".txt"
        
        if file.Exists(path, "DATA") then
            local data = util.JSONToTable(file.Read(path, "DATA"))
            self:SetNWString("AJMRP_Name", data.name)
            self:SetNWString("AJMRP_Backstory", data.backstory)
            self:SetNWString("AJMRP_Model", data.model)
            self:SetModel(data.model or "models/player/kleiner.mdl")
        else
            -- First join: Prompt character creation
            net.Start("AJMRP_CharacterCreation")
            net.Send(self)
        end
    end

    -- Save character data
    function PLAYER:SaveCharacter()
        local steamID = self:SteamID64()
        local path = "applejack_modernised/characters/" .. steamID .. ".txt"
        local data = {
            name = self:GetNWString("AJMRP_Name", "Citizen"),
            backstory = self:GetNWString("AJMRP_Backstory", ""),
            model = self:GetNWString("AJMRP_Model", "models/player/kleiner.mdl")
        }
        file.Write(path, util.TableToJSON(data))
    end

    -- Receive character creation data
    net.Receive("AJMRP_CharacterCreation", function(len, ply)
        local name = net.ReadString()
        local backstory = net.ReadString()
        local model = net.ReadString()
        
        -- Validate name
        local valid, err = IsValidName(name)
        if not valid then
            ply:ChatPrint("Character creation failed: " .. err)
            net.Start("AJMRP_CharacterCreation") -- Re-prompt
            net.Send(ply)
            return
        end
        
        -- Sanitize backstory
        backstory = string.sub(string.Trim(backstory), 1, 256)
        if backstory == "" then backstory = "No backstory provided." end
        
        -- Validate model
        local validModel = false
        for _, mdl in ipairs(AJMRP.Playermodels) do
            if mdl.model == model then
                validModel = true
                break
            end
        end
        model = validModel and model or AJMRP.Playermodels[1].model
        
        -- Apply character data
        ply:SetNWString("AJMRP_Name", name)
        ply:SetNWString("AJMRP_Backstory", backstory)
        ply:SetNWString("AJMRP_Model", model)
        ply:SetModel(model)
        ply:SaveCharacter()
        ply:ChatPrint("Character created successfully!")
    end)
end

if CLIENT then
    -- Show character creation UI
    net.Receive("AJMRP_CharacterCreation", function()
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 400) -- Increased height for model selection
        frame:Center()
        frame:SetTitle("Create Your Character")
        frame:MakePopup()

        local nameEntry = vgui.Create("DTextEntry", frame)
        nameEntry:SetPos(20, 40)
        nameEntry:SetSize(360, 30)
        nameEntry:SetPlaceholderText("Enter your character's name (3-32 chars)")

        local backstoryEntry = vgui.Create("DTextEntry", frame)
        backstoryEntry:SetPos(20, 80)
        backstoryEntry:SetSize(360, 100)
        backstoryEntry:SetMultiline(true)
        backstoryEntry:SetPlaceholderText("Enter a short backstory (optional)")

        local modelLabel = vgui.Create("DLabel", frame)
        modelLabel:SetPos(20, 190)
        modelLabel:SetSize(360, 20)
        modelLabel:SetText("Select your character model:")

        local modelCombo = vgui.Create("DComboBox", frame)
        modelCombo:SetPos(20, 210)
        modelCombo:SetSize(360, 30)
        for _, mdl in ipairs(AJMRP.Playermodels) do
            modelCombo:AddChoice(mdl.name, mdl.model)
        end
        modelCombo:SetValue(AJMRP.Playermodels[1].name)

        local preview = vgui.Create("DModelPanel", frame)
        preview:SetPos(20, 250)
        preview:SetSize(100, 100)
        preview:SetModel(AJMRP.Playermodels[1].model)
        function modelCombo:OnSelect(index, value, data)
            preview:SetModel(data)
        end

        local submit = vgui.Create("DButton", frame)
        submit:SetPos(20, 360)
        submit:SetSize(360, 30)
        submit:SetText("Submit")
        submit.DoClick = function()
            net.Start("AJMRP_CharacterCreation")
            net.WriteString(nameEntry:GetValue())
            net.WriteString(backstoryEntry:GetValue())
            net.WriteString(modelCombo:GetSelected() and modelCombo:GetSelected()[2] or AJMRP.Playermodels[1].model)
            net.SendToServer()
            frame:Close()
        end
    end)
end

-- Shared: Get character info
function PLAYER:GetCharacterName()
    return self:GetNWString("AJMRP_Name", "Citizen")
end

function PLAYER:GetCharacterBackstory()
    return self:GetNWString("AJMRP_Backstory", "")
end

function PLAYER:GetCharacterModel()
    return self:GetNWString("AJMRP_Model", "models/player/kleiner.mdl")
end