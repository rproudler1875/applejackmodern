if SERVER then
    AddCSLuaFile()
end

hook.Add("InitPostEntity", "AJMRP_RegisterPrinter", function()
    if scripted_ents.Get("base_gmodentity") then
        print("[AJMRP] base_gmodentity found, registering ajmrp_printer")
        -- No need for scripted_ents.Register; shared.lua handles it
    else
        print("[AJMRP] WARNING: base_gmodentity not found, using base_anim for ajmrp_printer")
    end
end)

print("[AJMRP] ajmrp_printer_fix.lua loaded")