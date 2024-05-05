function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city

    local newcity = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
    local destroyed = table.remove(newcity)
    getObjectFromGUID(pushvillainsguid).Call('updateCity',{newcity = newcity})
    local escapees = Global.Call('get_decks_and_cards_from_zone',destroyed)
    if escapees[1] then
        getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = escapees,
            currentZone = getObjectFromGUID(destroyed),
            targetZone = getObjectFromGUID(escape_zone_guid),
            enterscity = 0})
        for _,o in pairs(escapees) do
            if o.getDescription():find("LOCATION") then
                getObjectFromGUID(pushvillainsguid).Call('koCard',o)
            end
        end
    end
    local setStrike = function()
        if cards[1] then
            cards[1].setPositionSmooth(getObjectFromGUID(destroyed).getPosition())
        else
            getObjectFromGUID(mmPileGUID).takeObject({position = getObjectFromGUID(destroyed).getPosition(),
                smooth = false})
        end
    end
    Wait.time(setStrike,0.1)
    return nil
end