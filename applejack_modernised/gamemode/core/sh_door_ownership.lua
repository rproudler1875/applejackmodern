if SERVER then
    util.AddNetworkString("AJMRP_BuyDoor")
    util.AddNetworkString("AJMRP_UnbuyDoor")
    
    function CanBuyDoor(ply, ent)
        if not ent:IsDoor() then return false end
        if ent:GetNWString("AJMRP_Owner") != "" then return false end
        if ply:GetCredits() < AJMRP.Config.DoorPrice then
            ply:ChatPrint("Need " .. AJMRP.Config.DoorPrice .. " Credits!")
            return false
        end
        return true
    end
    
    concommand.Add("ajmrp_buy_door", function(ply)
        local ent = ply:GetEyeTrace().Entity
        if not IsValid(ent) or not CanBuyDoor(ply, ent) then return end
        ent:SetNWString("AJMRP_Owner", ply:SteamID())
        ply:AddCredits(-AJMRP.Config.DoorPrice)
        ply:ChatPrint("Door purchased for " .. AJMRP.Config.DoorPrice .. " Credits!")
    end)
    
    concommand.Add("ajmrp_unbuy_door", function(ply)
        local ent = ply:GetEyeTrace().Entity
        if not IsValid(ent) or not ent:IsDoor() then return end
        if ent:GetNWString("AJMRP_Owner") != ply:SteamID() then
            ply:ChatPrint("You don’t own this door!")
            return
        end
        ent:SetNWString("AJMRP_Owner", "")
        ply:ChatPrint("Door ownership removed!")
    end)
end