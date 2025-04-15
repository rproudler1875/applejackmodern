if SERVER then
    AddCSLuaFile()
    print("[AJMRP] ajmrp_entities.lua running on server")
else
    print("[AJMRP] ajmrp_entities.lua running on client")
end

-- Register entities
local entities = {
    "ajmrp_food",
    "ajmrp_medkit"
}

for _, ent in ipairs(entities) do
    print("[AJMRP] Registering entity: " .. ent)
    scripted_ents.Register({
        Type = "anim",
        Base = scripted_ents.Get("base_gmodentity") and "base_gmodentity" or "base_anim",
        PrintName = ent,
        Author = "Grok",
        Spawnable = true,
        Category = "AppleJack RP"
    }, ent)
end

print("[AJMRP] ajmrp_printer handled by shared.lua and ajmrp_printer_fix.lua")