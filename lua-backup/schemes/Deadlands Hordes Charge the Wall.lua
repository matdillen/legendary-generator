function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function deadlandsCharge(city)
    for i,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        local targetGUID = city[i+1]
        if not targetGUID then
            targetGUID = escape_zone_guid
        end
        if citycontent[1] then
            getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = {table.unpack(citycontent)},
                currentZone = getObjectFromGUID(o),
                targetZone = getObjectFromGUID(targetGUID),
                enterscity = 0})
        end
    end
end

function setupCounter(init)
    if init then
        local playercounter = 6+#Player.getPlayers()
        return {["tooltip"] = "Villains escaped: __/" .. playercounter .. ".",
                ["zoneguid"] = escape_zone_guid}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Villain"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Villain") then
            counter = counter + 1
        end
        return counter
    end
end

function resolveTwist(params)
    local cards = params.cards
    local city = params.city
    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    broadcastToAll("Scheme Twist: All villains charge twice, then another cards is played from the villain deck.")
    for i = 0,2 do
        Wait.time(function() deadlandsCharge(city) end,i+1)
    end
    Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('click_draw_villain') end,4)
    return nil
end