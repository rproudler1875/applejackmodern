SWEP.PrintName = "Keys"
SWEP.Author = "Grok"
SWEP.Purpose = "To lock and unlock owned doors"
SWEP.Instructions = "Left click: Lock door | Right click: Unlock door"
SWEP.Category = "AppleJack Modernised RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetHoldType("normal")
end

-- Prevent dropping the keys
function SWEP:CanDrop()
    return false
end

print("[AJMRP] weapon_ajmrp_keys/shared.lua loaded")