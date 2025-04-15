include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local credits = self:GetCredits()
    
    ang:RotateAroundAxis(ang:Up(), 90)
    
    cam.Start3D2D(pos + Vector(0, 0, 20), ang, 0.1)
        draw.RoundedBox(4, -50, -20, 100, 40, Color(0, 0, 0, 200))
        draw.SimpleText("Credits: " .. credits, "DermaDefault", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end