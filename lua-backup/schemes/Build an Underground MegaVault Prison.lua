function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
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
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local sewersCards = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[6])
    if sewersCards[1] then
        for i,o in pairs(sewersCards) do
            if o.hasTag("Villain") then
                getObjectFromGUID(pushvillainsguid).Call('dealWounds')
                broadcastToAll("Scheme Twist: There's a villain in the sewers! Everyone gets a wound!")
                return twistsresolved
            end
        end
    end
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
    if vildeck[1] then
        local pos = getObjectFromGUID(city_zones_guids[6]).getPosition()
        pos.y = pos.y + 3
        local enterSewers = function(name)
            getObjectFromGUID(pushvillainsguid).Call('click_draw_villain')
            Wait.condition(
                function()
                    getObjectFromGUID(pushvillainsguid).Call('checkCityContent2',{
                        color = Turns.turn_color,
                        customcity = {city_zones_guids[1],city_zones_guids[6]}})
                end,
                function()
                    local drawnvillain = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
                    if drawnvillain[1] then
                        for _,o in pairs(drawnvillain) do
                            if o.getName() == name then
                                return true
                            end
                        end
                    end
                    return false
                end
            )
        end
        if vildeck[1].tag == "Deck" then
            for _,o in pairs(vildeck[1].getObjects()[1].tags) do
                if o == "Villain" then
                    enterSewers(vildeck[1].getObjects()[1].name)
                    broadcastToAll("The top card of the villain deck enters the sewers!")
                    return twistsresolved
                end
            end
            local pos = vildeck[1].getPosition()
            pos.y = pos.y +3
            local showCardCallback = function(obj)
                broadcastToAll("Top card of villain deck is " .. obj.getName() .. ", not a villain!")
                Wait.time(function() obj.flip() end,1)
            end
            vildeck[1].takeObject({position = pos,flip=true,
                callback_function = showCardCallback})
        else 
            if vildeck[1].hasTag("Villain") then
                enterSewers(vildeck[1])
            else
                vildeck[1].flip()
                broadcastToAll("Top card of villain deck is " .. vildeck[1].getName() .. ", not a villain!")
                Wait.time(function() vildeck[1].flip() end,1)
            end
        end
    end
    return twistsresolved
end