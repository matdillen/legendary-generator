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

function cityShift(params)
    local obj = params.obj
    local currentZone = params.currentZone
    local targetZone = params.targetZone
    local enterscity = params.enterscity

    if targetZone.guid == escape_zone_guid and obj.hasTag("Alien Brood") then
        obj.removeTag("Alien Brood")
        obj.flip()
        local result = resolve_alien_brood_scan({obj = obj,escaping = true})
        replaceScanButton(obj,currentZone)
        if not result then
            return nil
        end
    elseif obj.hasTag("Alien Brood") and enterscity == 0 then
        targetZone.Call('removeFightButton')
        addScanButton(targetZone)
        replaceScanButton(obj,currentZone)
    end
    return obj
end

function replaceScanButton(obj,currentZone)
    Wait.condition(
        function()
            local content = Global.Call('get_decks_and_cards_from_zone',currentZone.guid)
            if content[1] then
                for _,o in pairs(content) do
                    if o.hasTag("Alien Brood") then
                        return nil
                    end
                end
            end
            removeScanButton(currentZone)
            currentZone.Call('addFightButton')
        end,
        function()
            local content = Global.Call('get_decks_and_cards_from_zone',currentZone.guid)
            if content[1] then
                for _,o in pairs(content) do
                    if o.guid == obj.guid then
                        return false
                    end
                end
            end
            if obj.isSmoothMoving() or obj.getPosition().y > 2.5 then
                return false
            else
                return true
            end
        end)
end

function nonTwist(params)
    local obj = params.obj
    local city = params.city
    local targetZone = params.targetZone

    if obj.is_face_down then
        obj.addTag("Alien Brood")
        if city then
            getObjectFromGUID(pushvillainsguid).Call('push_all2',city)
        end
        getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{
            objects = {obj},
            currentZone = getObjectFromGUID(city_zones_guids[1]),
            targetZone = targetZone,
            enterscity = 1})
        targetZone.Call('removeFightButton')
        addScanButton(targetZone)
        return nil
    else
        removeScanButton(targetZone)
        targetZone.Call('addFightButton')
        return 1
    end
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
        Wait.condition(
            function() 
                zone.Call('updatePower') 
            end,
            function()
                if not obj.is_face_down then
                    return true
                else
                    return false
                end
            end)
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
        return resolveTwist({cards = {obj}})
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
            removeScanButton(obj)
            obj.Call('addFightButton')
        end
    end
end

function addScanButton(obj)
    local butt = obj.getButtons()
    if butt then
        for _,b in pairs(butt) do
            if b.click_function == "scan_villain" then
                return nil
            end
        end
    end
    obj.createButton({label = "Scan",
        position={0,-0.4,-0.4}, 
        rotation = {0,180,0},
        click_function = 'scan_villain',
        function_owner = self,
        tooltip = "Scan the face down card in this city space for 1 attack.",
        color={1,0.65,0,0.9}, 
        font_color = {0,0,0}, 
        width=750, 
        height=150,
        font_size = 75})
end

function removeScanButton(obj)
    Global.Call('removeButton',{obj = obj,click_f = "scan_villain"})
end

function setupCounter(init)
    if init then
        local playercounter = 3*#Player.getPlayers()
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
    local obj = params.cards[1]

    local color = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
    obj.setName("Brood Infection")
    obj.setPositionSmooth(getObjectFromGUID(discardguids[color]).getPosition())
    broadcastToAll("Player " .. color .. " got a Brood Infection!")
    return nil
end