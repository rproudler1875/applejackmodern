local PLAYER = FindMetaTable("Player")

function PLAYER:GetJob()
    return self:GetNWString("AJMRP_Job", "citizen")
end

function PLAYER:GetJobTier()
    return self:GetNWInt("AJMRP_JobTier", 1)
end

function PLAYER:GetJobXP()
    return self:GetNWInt("AJMRP_JobXP", 0)
end

function PLAYER:SetJob(jobID)
    if not AJMRP.Config.Jobs[jobID] then
        jobID = "citizen"
    end
    self:SetNWString("AJMRP_Job", jobID)
    self:SaveJob()
end

function PLAYER:SetJobTier(tier)
    self:SetNWInt("AJMRP_JobTier", math.max(1, tier))
    self:SaveJob()
end

function PLAYER:AddJobXP(amount)
    local jobID = self:GetJob()
    local tier = self:GetJobTier()
    local xp = self:GetJobXP() + amount
    local thresholds = AJMRP.Config.Jobs[jobID].xpThresholds
    
    self:SetNWInt("AJMRP_JobXP", xp)
    
    if thresholds[tier] and xp >= thresholds[tier] then
        self:SetJobTier(tier + 1)
        self:SetNWInt("AJMRP_JobXP", 0)
        self:ChatPrint("Promoted to " .. AJMRP.Config.Jobs[jobID].name .. " Tier " .. (tier + 1) .. "!")
    end
    self:SaveJob()
end

function PLAYER:SaveJob()
    local steamID = self:SteamID64()
    local path = "applejack_modernised/jobs/" .. steamID .. ".txt"
    file.Write(path, util.TableToJSON({
        job = self:GetJob(),
        tier = self:GetJobTier(),
        xp = self:GetJobXP()
    }))
end

function PLAYER:LoadJob()
    local steamID = self:SteamID64()
    local path = "applejack_modernised/jobs/" .. steamID .. ".txt"
    if file.Exists(path, "DATA") then
        local data = util.JSONToTable(file.Read(path, "DATA"))
        self:SetNWString("AJMRP_Job", data.job or "citizen")
        self:SetNWInt("AJMRP_JobTier", data.tier or 1)
        self:SetNWInt("AJMRP_JobXP", data.xp or 0)
    else
        self:SetNWString("AJMRP_Job", "citizen")
        self:SetNWInt("AJMRP_JobTier", 1)
        self:SetNWInt("AJMRP_JobXP", 0)
    end
end

if SERVER then
    net.Receive("AJMRP_SwitchJob", function(len, ply)
        local jobID = net.ReadString()
        if not AJMRP.Config.Jobs[jobID] then
            ply:ChatPrint("Invalid job!")
            return
        end
        if jobID == ply:GetJob() then
            ply:ChatPrint("You’re already this job!")
            return
        end
        if ply.firstJoin then
            ply:SetJob(jobID)
            ply:SetJobTier(1)
            ply:SetNWInt("AJMRP_JobXP", 0)
            ply:ChatPrint("Switched to " .. AJMRP.Config.Jobs[jobID].name .. "!")
            ply.firstJoin = false
            ply:SetNWInt("AJMRP_JobSwitchTime", CurTime())
            return
        end
        local lastSwitch = ply:GetNWInt("AJMRP_JobSwitchTime", 0)
        local cooldown = 300
        if CurTime() - lastSwitch < cooldown then
            ply:ChatPrint("Wait " .. math.ceil(cooldown - (CurTime() - lastSwitch)) .. " seconds to switch jobs!")
            return
        end
        ply:SetJob(jobID)
        ply:SetJobTier(1)
        ply:SetNWInt("AJMRP_JobXP", 0)
        ply:SetNWInt("AJMRP_JobSwitchTime", CurTime())
        ply:ChatPrint("Switched to " .. AJMRP.Config.Jobs[jobID].name .. "!")
    end)
end