function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "sidekickDeckGUID",
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
    if twistsresolved < 8 then
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,k in pairs(citycontent) do
                    if k.hasTag("Villain") then
                        local pos = k.getPosition()
                        pos.z = pos.z - 2
                        local skpile = getObjectFromGUID(sidekickDeckGUID)
                        if skpile then
                            skpile.takeObject({position=pos,flip=true})
                            --if not, check if one card left
                            --otherwise give an officer
                        end
                        --still annotate villain's power boost
                        --also goes in updatePower
                        break
                    end
                end
            end
        end
    elseif twistsresolved == 8 then
        broadcastToAll("Scheme Twist 8: All heroes in the city escape (don't KO anything)!")
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,k in pairs(citycontent) do
                    if k.hasTag("Sidekick") or k.hasTag("Officer") or hasTag2(k,"Cost:") then
                        k.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                    end
                end
            end
        end
    end
    return twistsresolved
end