function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "schemeZoneGUID",
        "escape_zone_guid"
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

    getObjectFromGUID(pushvillainsguid).Call('cityLowTides')
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
    
    if twistsresolved % 2 == 1 then
        self.flip()
        self.setPositionSmooth(getObjectFromGUID(city_zones_guids[5]).getPosition())
        local newcity = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
        for i = 1,4 do
            local guid = table.remove(newcity)
            local content = Global.Call('get_decks_and_cards_from_zone',guid)
            if content[1] then
                getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{
                    objects = table.clone(content),
                    currentZone = getObjectFromGUID(guid),
                    targetZone = getObjectFromGUID(escape_zone_guid),
                    enterscity = 0})
            end
            if i > 2 then
                getObjectFromGUID(guid).Call('toggleButton')
            else
                getObjectFromGUID(guid).clearButtons()
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('updateCity',{newcity = newcity})
        broadcastToAll("Scheme Twist: The tide rushes in and the city is now only three spaces.")
    else
        self.locked = false
        self.flip()
        self.setPositionSmooth(getObjectFromGUID(schemeZoneGUID).getPosition())
        getObjectFromGUID(pushvillainsguid).Call('updateCity',{newcity = city_zones_guids})
        getObjectFromGUID(pushvillainsguid).Call('cityLowTides')
        local newcity = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
        for i = 5,6 do
            getObjectFromGUID(newcity[i]).Call('toggleButton')
        end
        broadcastToAll("Scheme Twist: The tide rushes out and the city is now seven spaces.")
        getObjectFromGUID(pushvillainsguid).Call('click_draw_villain')
    end
    return twistsresolved
end