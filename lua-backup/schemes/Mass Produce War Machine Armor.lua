function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

    local twistpile = getObjectFromGUID(twistZoneGUID)
    local twistcount = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    if twistcount[1] then
        twistcountPrevious = twistcount[1].getQuantity()
    else
        twistcountPrevious = 0
    end
    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    local twistMoved = function()
        local twist = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
        if twist[1] and twist[1].getQuantity() ~= twistcountPrevious then
            return true
        else
            return false
        end
    end
    Wait.condition(function() getObjectFromGUID(pushvillainsguid).Call('updatePower') end,twistMoved)
    local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[Turns.turn_color])
    if vpile[1] then
        local updateAndPush = function()
            getObjectFromGUID(pushvillainsguid).Call('updatePower')
            getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
        end
        if vpile[1].tag == "Deck"  then
            local vpileCards = vpile[1].getObjects()
            for j = 1, vpile[1].getQuantity() do
                if vpileCards[j].name == "S.H.I.E.L.D. Assault Squad" then
                    vpile[1].takeObject({position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                        guid=vpileCards[j].guid,
                        callback_function = updateAndPush})
                    break
                end
            end
        else
            if vpile[1].getName() == "S.H.I.E.L.D. Assault Squad" then
                vpile[1].clearButtons()
                vpile[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                local squadMoved = function()
                    local squad = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
                    if squad[1] and squad[1].getName() == "S.H.I.E.L.D. Assault Squad" then
                        return true
                    else
                        return false
                    end
                end
                Wait.condition(updateAndPush,squadMoved)
            end
        end
    end
    return nil
end