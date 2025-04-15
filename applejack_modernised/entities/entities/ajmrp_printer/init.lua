AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = "models/props_lab/harddrive02.mdl"

function ENT:Initialize()
    print("[AJMRP] Spawning printer: " .. self:EntIndex())
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(50)
    end
    
    self:SetCredits(0)
    self.timer = CurTime()
    self.owner = self.owner or NULL
end

function ENT:Think()
    if CurTime() - self.timer >= 60 then
        local credits = self:GetCredits() + 100
        self:SetCredits(credits)
        self.timer = CurTime()
        
        if credits >= 1000 then
            if IsValid(self.owner) then
                self.owner:AddCredits(credits)
                self.owner:ChatPrint("Collected " .. credits .. " Credits!")
                self:SetCredits(0)
            end
        end
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if activator == self.owner then
        local credits = self:GetCredits()
        if credits > 0 then
            activator:AddCredits(credits)
            activator:ChatPrint("Collected " .. credits .. " Credits!")
            self:SetCredits(0)
        end
    elseif activator:GetJob() == "police" then
        if IsValid(self.owner) then
            self.owner:ChatPrint("Your printer was destroyed by Police!")
        end
        activator:AddJobXP(20)
        activator:ChatPrint("Destroyed printer, gained 20 XP!")
        
        local effect = EffectData()
        effect:SetOrigin(self:GetPos())
        util.Effect("Explosion", effect)
        self:Remove()
    end
end

function ENT:OnRemove()
    if IsValid(self.owner) then
        self.owner.printer = nil
    end
end