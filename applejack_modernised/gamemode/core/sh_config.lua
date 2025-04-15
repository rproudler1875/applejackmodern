AJMRP = AJMRP or {}
AJMRP.Config = AJMRP.Config or {}

-- Define Jobs table for HUD and other systems
AJMRP.Config.Jobs = {
    ["citizen"] = { name = "Citizen", xpThresholds = { 1000, 2000, 3000 } },
    ["police"] = { name = "Police", xpThresholds = { 1500, 2500, 3500 } },
    ["gangster"] = { name = "Gangster", xpThresholds = { 1200, 2200, 3200 } },
    ["shopkeeper"] = { name = "Shopkeeper", xpThresholds = { 1000, 2000, 3000 } },
    ["mayor"] = { name = "Mayor", xpThresholds = { 2000, 3000, 4000 } },
    ["paramedic"] = { name = "Paramedic", xpThresholds = { 1000, 2000, 3000 } },
    ["hacker"] = { name = "Hacker", xpThresholds = { 1200, 2200, 3200 } },
    ["driver"] = { name = "Delivery Driver", xpThresholds = { 1000, 2000, 3000 } },
    ["vigilante"] = { name = "Vigilante", xpThresholds = { 1200, 2200, 3200 } },
}

-- Economy Items with descriptions
AJMRP.Config.Items = {
    pistol = {
        name = "Pistol",
        description = "A small firearm for self-defense.",
        price = 200,
        weight = 2,
        entity = "weapon_pistol",
        jobs = { "Citizen", "Gangster" }
    },
    smg = {
        name = "SMG",
        description = "A rapid-fire submachine gun for combat.",
        price = 350,
        weight = 3,
        entity = "weapon_smg1",
        jobs = { "Gangster" }
    },
    food = {
        name = "Food",
        description = "A meal to restore your hunger.",
        price = 50,
        weight = 1,
        jobs = { "Citizen", "Gangster", "Paramedic" }
    },
    medkit = {
        name = "Medkit",
        description = "A medical kit to heal injuries.",
        price = 100,
        weight = 2,
        entity = "ajmrp_medkit",
        jobs = { "Paramedic" }
    },
    printer = {
        name = "Money Printer",
        description = "A device that generates credits over time.",
        price = 500,
        weight = 5,
        entity = "ajmrp_printer",
        jobs = { "Gangster", "Hacker" }
    }
}

-- Stamina Config
AJMRP.Config.MaxStamina = 100
AJMRP.Config.StaminaDrain = 0.25 -- per second while sprinting
AJMRP.Config.StaminaRegen = 0.5 -- per second while standing still
AJMRP.Config.StaminaRegenMoving = 0.2 -- per second while moving (not sprinting)
AJMRP.Config.StaminaRegenDelay = 1 -- Delay before stamina regenerates (in seconds)
AJMRP.Config.StaminaJumpCost = 5 -- Stamina cost per jump

-- Hunger Config
AJMRP.Config.MaxHunger = 100
AJMRP.Config.HungerDrain = 0.1 -- per second

-- HUD Config
AJMRP.Config.HUDColor = Color(50, 50, 50, 180) -- Transparent gray

print("[AJMRP] sh_config.lua loaded")
