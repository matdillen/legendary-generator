function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    local city = params.city
    if twistsresolved < 7 then
        getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
        Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('updatePower') end,1)
        broadcastToAll("Scheme Twist: Another card was played from the villain deck!")
        return nil
    elseif twistsresolved == 7 then
        broadcastToAll("Scheme Twist: All SHIELD Officers in the city escape!")
        for _,o in pairs(city) do
            local cardsincity = Global.Call('get_decks_and_cards_from_zone',o) 
            if cardsincity[1] then
                for _,object in pairs(cardsincity) do
                    if object.hasTag("Officer") == true then
                        object.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                        broadcastToAll("S.H.I.E.L.D. Officer escaped!",{r=1,g=0,b=0})
                    end
                end
            end
        end
    end
    return twistsresolved
end