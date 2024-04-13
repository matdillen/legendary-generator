function onLoad()
    local guids1 = {
        "pushvillainsguid",
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

    local guids3 = {
        "attackguids",
        "discardguids",
        "handguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o))
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

function cityShift(params)
    local obj = params.obj
    if params.targetZone.guid == escape_zone_guid and obj.hasTag("Alien Brood") then
        obj.removeTag("Alien Brood")
        obj.flip()
        local result = resolve_alien_brood_scan({obj = obj,escaping = true})
        if not result then
            return nil
        end
    end
    return obj
end

function resolve_alien_brood_scan(params)
    local obj = params.obj
    local escaping = params.escaping
    local zone = params.zone
    
    if obj.getName() == "Masterstrike" then
        obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
        Wait.time(function()
            getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
        end,1)
        broadcastToAll("A master strike was scanned in the city!")
        return nil
    elseif obj.getDescription():find("TRAP") then
        obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
        broadcastToAll("A Trap was scanned in the city! Resolve it by end of turn or suffer the consequences.")
        return nil
    elseif (obj.hasTag("Villain") or obj.hasTag("Villainous Weapon")) and escaping then
        getObjectFromGUID(pushvillainsguid).Call('nonTwistspecials2',{cards = {obj},city = {}})
        return obj
    elseif obj.hasTag("Villain") and zone then
        zone.Call('updatePower')
    elseif obj.hasTag("Location") then
        if escaping then
            getObjectFromGUID(pushvillainsguid).Call('koCard',obj)
            broadcastToAll("Locations can't normally escape, so it was KO'd instead.")
            return nil
        else
            pos = obj.getPosition()
            pos.z = pos.z + 1.5
            obj.setPosition(pos)
            return nil
        end
    elseif obj.getName() == "Scheme Twist" then
        local color = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
        obj.setName("Brood Infection")
        obj.setPositionSmooth(getObjectFromGUID(discardguids[color]).getPosition())
        broadcastToAll("Player " .. color .. " got a Brood Infection!")
        return nil
    end
end

function onObjectEnterZone(zone,object)
    if object.getName() == "Brood Infection" then
        for i,o in pairs(handguids) do
            if zone.guid == o then
                object.setName("Scheme Twist")
                Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('koCard',object) end,0.1)
                getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                broadcastToColor("You drew a Brood Infection! It was KO'd but gave you two wounds.",i,i)
            end
        end
    end
end

function setupSpecial(params)
    for i,guid in pairs(city_zones_guids) do
        if i ~= 1 then
            getObjectFromGUID(guid).editButton({index = 0,
                label = "Scan",
                click_function = 'scan_villain',
                function_owner = self,
                tooltip = "Scan the face down card in this city space for 1 attack."})
        end
    end 
end

function scan_villain(obj,player_clicker_color)
    local cards = Global.Call('get_decks_and_cards_from_zone',obj.guid)
    if not cards[1] then
        return nil
    end
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < 1 then
        broadcastToColor("You don't have enough attack to scan this city space!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-1)
    for _,o in pairs(cards) do
        if o.hasTag("Alien Brood") then
            o.removeTag("Alien Brood")
            o.flip()
            resolve_alien_brood_scan({obj = o,zone = obj})
            obj.editButton({index = 0,
                label = obj.Call('returnZoneName'), 
                tooltip = "Fight the villain in this city space!", 
                click_function = 'click_fight_villain',
                function_owner = obj})
        end
    end
end