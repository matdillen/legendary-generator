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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    local vildeckcurrentcount = 0
    if vildeck then
        vildeckcurrentcount = math.abs(vildeck.getQuantity())
    end
    local sentinelsfound = 0
    for _,o in pairs(Player.getPlayers()) do
        local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])[1]
        local copguids = {}
        if vpilecontent and vpilecontent.tag == "Deck" then
            local vpileCards = vpilecontent.getObjects()
            for j = 1, #vpileCards do
                if vpileCards[j].name == "Sentinel" then
                    table.insert(copguids,vpileCards[j].guid)
                    sentinelsfound = sentinelsfound + 1
                end
            end
            for j = 1,#copguids do
                if not vpilecontent.remainder then
                    vpilecontent.takeObject({position=vildeckzone.getPosition(),
                        guid=copguids[j],flip=true})
                else
                    vpilecontent.remainder.flip()
                    vpilecontent.remainder.setPositionSmooth(vildeckzone.getPosition())
                end  
            end
        elseif vpilecontent then
            if vpilecontent.getName() == "Sentinel" then
                vpilecontent.flip()
                vpilecontent.setPositionSmooth(vildeckzone.getPosition())
                sentinelsfound = sentinelsfound + 1
            end
        end
    end
    local sentinelsAdded = function()
        local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
        if vildeck and vildeck.getQuantity() == vildeckcurrentcount + sentinelsfound then
            return true
        else
            return false
        end
    end
    local sentinelsNext = function()
        if sentinelsfound > 0 then
            Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1].randomize()
        end
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
        etObjectFromGUID(pushvillainsguid).Call('updatePower')
    end
    Wait.condition(sentinelsNext,sentinelsAdded)
    return nil
end
