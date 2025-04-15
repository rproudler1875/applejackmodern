AJMRP = AJMRP or {}
AJMRP.Config = AJMRP.Config or {}

-- Economy Items
AJMRP.Config.Items = {
    pistol = {
        name = "Pistol",
        price = 200,
        weight = 2,
        entity = "weapon_pistol",
        jobs = { "Citizen", "Gangster" }
    },
    smg = {
        name = "SMG",
        price = 350,
        weight = 3,
        entity = "weapon_smg1",
        jobs = { "Gangster" }
    },
    food = {
        name = "Food",
        price = 50,
        weight = 1,
        jobs = { "Citizen", "Gangster", "Paramedic" }
    },
    medkit = {
        name = "Medkit",
        price = 100,
        weight = 2,
        entity = "ajmrp_medkit",
        jobs = { "Paramedic" }
    },
    printer = {
        name = "Money Printer",
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

-- Hunger Config
AJMRP.Config.MaxHunger = 100
AJMRP.Config.HungerDrain = 0.1 -- per second

-- HUD Config
AJMRP.Config.HUDColor = Color(50, 50, 50, 180) -- Transparent gray

print("[AJMRP] sh_config.lua loaded")