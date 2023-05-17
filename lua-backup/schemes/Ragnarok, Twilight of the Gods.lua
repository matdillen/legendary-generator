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

function pushTwilightVillain(params)
    params.obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
    Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city') end,1)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[Turns.turn_color])[1]
    cards[1].setName("Guardian Defeated")
    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if vpile and vpile.tag == "Deck" then
        local villainguids = {}
        for _,o in pairs(vpile.getObjects()) do
            for _,tag in pairs(o.tags) do
                if tag:find("VP") and tonumber((tag:gsub("VP",""))) > 1 then
                    table.insert(villainguids,o.guid)
                    break
                end
            end
        end
        if #villainguids > 1 then
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = Turns.turn_color,
                pile = vpile,
                guids = villainguids,
                resolve_function = 'pushTwilightVillain',
                tooltip = "Push this villain into the city.",
                label = "Push",
                fsourceguid = self.guid})
            broadcastToColor("Scheme Twist: Choose a villain from your victory pile with VP 2 or more to enter the city.",Turns.turn_color,Turns.turn_color)
        elseif villainguids[1] then
            vpile.takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                smooth = false,
                guid = villainguids[1],
                callback_function = function() getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city') end})
            broadcastToColor("Scheme Twist: The villain from your victory pile with VP 2 or more enters the city.",Turns.turn_color,Turns.turn_color)
        end
    elseif vpile and hasTag2(vpile,"VP") and hasTag2(vpile,"VP") > 1 then
        pushTwilightVillain({obj = vpile})
        broadcastToColor("Scheme Twist: The villain from your victory pile with VP 2 or more enters the city.",Turns.turn_color,Turns.turn_color)
    end
    local ragnarokGuardians = {
        {"Balder",11},
        {"Odin",24},
        {"Vidar",19},
        {"Tyr",16},
        {"Heimdall",12},
        {"Frey",7},
        {"Frigga",8},
        {"Warriors of Valhalla",6}
    }
    if twistsresolved < 8 then
        broadcastToAll("If the total power of villains (after choosing one from your victory pile to enter) is not greater than the power of Guardian " 
            .. ragnarokGuardians[twistsresolved][1] .. 
            " (" .. ragnarokGuardians[twistsresolved][2] .. ") then you can move the last twist from next to the scheme to the KO pile.")
    elseif twistsresolved < 12 then
        broadcastToAll("If the total power of villains (after choosing one from your victory pile to enter) is not greater than the power of Guardian " 
            .. ragnarokGuardians[8][1] .. 
            " (" .. ragnarokGuardians[8][2] .. ") then you can move the last twist from next to the scheme to the KO pile.")
    end
    return nil
end
