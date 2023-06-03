function onLoad()
    mmname = "Hela, Goddess of Death"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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
        "vpileguids"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMHela()
    local villaincount = 0
    for _,o in pairs(helacitycheck) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if obj.hasTag("Villain") then
                    villaincount = villaincount + 1
                    break
                end
            end
        end
    end
    local boost = 0
    if epicness then
        boost = 1
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = villaincount,
        label = "+" .. villaincount*(5+boost),
        tooltip = "Hela gets +" .. 5+boost .. " for each Villain in the city zones she wants to conquer.",
        f = 'updateMMHela',
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    helacitycheck = table.clone(city_zones_guids)
    table.remove(helacitycheck,1)
    table.remove(helacitycheck,1)
    table.remove(helacitycheck,1)
    if not epicness then
        table.remove(helacitycheck,1)
    end
    updateMMHela()
    function onObjectEnterZone(zone,object)
        if object.hasTag("Villain") then
            updateMMHela()
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.hasTag("Villain") then
            updateMMHela()
        end
    end
end

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function moveToCity(params)
    params.obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
    Wait.time(click_push_villain_into_city,2)
end

function resolveStrike(params)
    local cards = params.cards
    local epicness = params.epicness

    if cards[1] then
        helabonus = 0
        if epicness then
            helabonus = 1
        end
        cards[1].setName("Army of the Dead")
        cards[1].addTag("VP" .. 3 + helabonus)
        cards[1].addTag("Power:" .. 5 + helabonus)
        cards[1].addTag("Villain")
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
            label = 5 + helabonus,
            tooltip = "This strike is an Army of the Dead villain."})
        getObjectFromGUID(pushvillainsguid).Call('push_all')
    else
        broadcastToAll("No Master Strike found, so Hela failed to muster an Army of the Dead.")
    end
    local pcolor = Turns.turn_color
    local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[pcolor])
    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
        local vpilestrong = {}
        for _,o in pairs(vpilecontent[1].getObjects()) do
            for _,k in pairs(o.tags) do
                if k:find("VP") and tonumber(k:match("%d+")) > 2 + helabonus then
                    table.insert(vpilestrong,o.guid)
                    break
                end
            end
        end
        --log(vpilestrong)
        if vpilestrong[1] and not vpilestrong[2] then
            local pushDelayed = function()
                Wait.time(click_push_villain_into_city,2)
            end
            vpilecontent[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                smooth = true,
                callback_function = pushDelayed})
            return nil
        elseif vpilestrong[1] and vpilestrong[2] then
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = pcolor,
                pile = vpilecontent[1],
                guids = vpilestrong,
                resolve_function = 'moveToCity',
                args = "self",
                fsourceguid = self.guid})
            return nil
        end
    end
    if vpilecontent[1] and vpilecontent[1].tag == "Card" then
        if hasTag2(vpilecontent[1],"VP") and hasTag2(vpilecontent[1],"VP") > 2 + helabonus then
            moveToCity({obj = vpilecontent[1]})
            return nil
        end
    end
    getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    return nil
end
