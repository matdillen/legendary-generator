function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "vpileguids"
        }
            
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
end

function table.clone(org,key)
    if key then
        local new = {}
        for i,o in pairs(org) do
            new[i] = o
        end
        return new
    else
        return {table.unpack(org)}
    end
end

function sinisterSixReturns(params)
    params.obj.flip()
    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
    pos.y = pos.y + 2
    params.obj.setPositionSmooth(pos)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    broadcastToAll("Each player puts a Sinister Six villain from their Victory Pile on top of the villain deck. Then, a single card from the villain deck is played.")
    local ssfound = 0
    local vildeckcount = math.abs(Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1].getQuantity())
    --breaks if no villain deck left, but this should end the game
    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
    pos.y = pos.y + 2
    for _,o in pairs(Player.getPlayers()) do
        local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])[1]
        if vpile and vpile.tag == "Deck" then
            local ssguids = {}
            for _,obj in pairs(vpile.getObjects()) do
                for _,tag in pairs(obj.tags) do
                    if tag == "Group:Sinister Six" then
                        table.insert(ssguids,obj.guid)
                        break
                    end
                end
            end
            if #ssguids > 1 then
                ssfound = ssfound + 1
                offerCards({color = o.color,
                    pile = vpile,
                    guids = ssguids,
                    resolve_function = 'sinisterSixReturns',
                    args = "self",
                    tooltip = "Return this Sinister Six villain to the top of the villain deck.",
                    label = "Return",
                    fsourceguid = self.guid})
            elseif ssguids[1] then
                ssfound = ssfound + 1
                vpile.takeObject({position = pos,
                    flip = true,
                    guid = ssguids[1]})
            end
        elseif vpile and vpile.hasTag("Group:Sinister Six") then
            vpile.flip()
            ssfound = ssfound + 1
            vpile.setPositionSmooth(pos)
        end
    end
    local ssAdded = function()
        local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
        if vildeck.getQuantity() == ssfound + vildeckcount then
            return true
        else
            return false
        end
    end
    Wait.condition(function() getObjectFromGUID(pushvillainsguid).Call('playVillains') end,ssAdded)
    return twistsresolved
end
