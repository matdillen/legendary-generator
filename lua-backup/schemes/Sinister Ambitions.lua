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

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved < 6 then
        getObjectFromGUID(pushvillainsguid).Call('updatePower')
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    elseif twistsresolved == 6 then
        getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
        for _,o in pairs(city) do
            local citycards = Global.Call('get_decks_and_cards_from_zone',o)
            if citycards[1] then
                for _,o in pairs(citycards) do
                    if o.hasTag("Ambition") then
                        getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = citycards,
                            targetZone = getObjectFromGUID(escape_zone_guid),
                            enterscity = 0,
                            schemeParts = {self.getName()}})
                        broadcastToAll("Scheme Twist: Ambition villain escapes!")
                        break
                    end
                end
            end
        end
    end
    return nil
end
