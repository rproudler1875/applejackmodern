-- Economy Items with descriptions
AJMRP.Config.Items = {
    pistol = {
        name = "Pistol",
        description = "A small firearm for self-defense.",
        price = 200,
        weight = 2,
        entity = "weapon_pistol",
        jobs = { "citizen", "gangster" } -- Updated to lowercase
    },
    smg = {
        name = "SMG",
        description = "A rapid-fire submachine gun for combat.",
        price = 350,
        weight = 3,
        entity = "weapon_smg1",
        jobs = { "gangster" } -- Updated to lowercase
    },
    food = {
        name = "Food",
        description = "A meal to restore your hunger.",
        price = 50,
        weight = 1,
        jobs = { "citizen", "gangster", "paramedic" } -- Updated to lowercase
    },
    medkit = {
        name = "Medkit",
        description = "A medical kit to heal injuries.",
        price = 100,
        weight = 2,
        entity = "ajmrp_medkit",
        jobs = { "paramedic" } -- Updated to lowercase
    },
    printer = {
        name = "Money Printer",
        description = "A device that generates credits over time.",
        price = 500,
        weight = 5,
        entity = "ajmrp_printer",
        jobs = { "gangster", "hacker" } -- Updated to lowercase
    }
}
