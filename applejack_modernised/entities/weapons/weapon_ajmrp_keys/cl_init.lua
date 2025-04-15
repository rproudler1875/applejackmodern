include("shared.lua")

-- Draw HUD hint
function SWEP:DrawHUD()
    draw.SimpleText("Left Click: Lock Door", "DermaDefault", ScrW() / 2, ScrH() - 60, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.SimpleText("Right Click: Unlock Door", "DermaDefault", ScrW() / 2, ScrH() - 40, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

print("[AJMRP] weapon_ajmrp_keys/cl_init.lua loaded")