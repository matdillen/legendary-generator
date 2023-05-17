function onLoad()
    local guids1 = {
        "pushvillainsguid"
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

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local city = params.city
    local mmloc = params.mmlocc

    local mm = Global.Call('get_decks_and_cards_from_zone',mmloc)
    local kinghyperion = nil
    if mm[1] then
        for _,o in pairs(mm) do
            if o.getName() == "King Hyperion" and o.tag == "Card" then
                kinghyperion = o
                break
            end
        end
    end
    if not kinghyperion then   
        for index,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if obj.getName() == "King Hyperion" then
                        local kingscity = table.clone(city)
                        if index > 2 then
                            for i = 1,index-2 do
                                table.remove(kingscity,1)
                            end
                        end
                        local stop = math.min(#kingscity-1,3)
                        local pushKing = function()
                            table.remove(kingscity,1)
                            getObjectFromGUID(pushvillainsguid).Call('push_all',table.clone(kingscity))
                        end
                        broadcastToAll("Charging...",{1,0,0})
                        for i=1,stop do
                            Wait.time(pushKing,1.5*i)
                            Wait.time(function() broadcastToAll("Still charging...",{1,0,0}) end,1.5*i)
                        end
                        return strikesresolved
                    end
                end
            end
        end
    end
    if not kinghyperion then
        broadcastToAll("King Hyperion not found?")
        return nil
    end
    --koCard(cards[1],true)
    kinghyperion.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
    if cards[1] then
        local pos = cards[1].getPosition()
        pos.x = pos.x + 5
        kinghyperstrike = cards[1]
        kinghyperstrike.setPosition(pos)
        pos.x = pos.x - 5
        local moveStrikeBack = function()
            kinghyperstrike.setPosition(pos)
            kinghyperstrike = nil
        end
        Wait.time(moveStrikeBack,6.5)
    end
    broadcastToAll("Charging...",{1,0,0})
    for i=1,4 do
        Wait.time(click_push_villain_into_city,1.5*i)
        Wait.time(function() broadcastToAll("Still charging...",{1,0,0}) end,1.5*i)
    end
    return strikesresolved
end
