GM.Name = "AppleJack Modernised RP"
GM.Author = "Grok and You"
GM.Email = ""
GM.Website = ""

-- Define teams
TEAM_CITIZEN = 1
TEAM_POLICE = 2
TEAM_GANGSTER = 3
TEAM_SHOPKEEPER = 4
TEAM_MAYOR = 5
TEAM_PARAMEDIC = 6
TEAM_HACKER = 7
TEAM_DRIVER = 8
TEAM_VIGILANTE = 9

team.SetUp(TEAM_CITIZEN, "Citizen", Color(100, 100, 100))
team.SetUp(TEAM_POLICE, "Police", Color(0, 0, 255))
team.SetUp(TEAM_GANGSTER, "Gangster", Color(255, 0, 0))
team.SetUp(TEAM_SHOPKEEPER, "Shopkeeper", Color(0, 255, 0))
team.SetUp(TEAM_MAYOR, "Mayor", Color(255, 255, 0))
team.SetUp(TEAM_PARAMEDIC, "Paramedic", Color(0, 255, 255))
team.SetUp(TEAM_HACKER, "Hacker", Color(128, 0, 128))
team.SetUp(TEAM_DRIVER, "Delivery Driver", Color(255, 165, 0))
team.SetUp(TEAM_VIGILANTE, "Vigilante", Color(128, 128, 128))

-- Define player meta for hunger/stamina
local PLAYER = FindMetaTable("Player")

function PLAYER:GetHunger()
    return self:GetNWInt("AJMRP_Hunger", AJMRP.Config.MaxHunger)
end

function PLAYER:SetHunger(amount)
    self:SetNWInt("AJMRP_Hunger", math.Clamp(amount, 0, AJMRP.Config.MaxHunger))
end

function PLAYER:GetStamina()
    return self:GetNWFloat("AJMRP_Stamina", AJMRP.Config.MaxStamina)
end

function PLAYER:SetStamina(amount)
    self:SetNWFloat("AJMRP_Stamina", math.Clamp(amount, 0, AJMRP.Config.MaxStamina))
end