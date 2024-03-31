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
        "drawguids"
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

function bonusInCity(params)
    if params.object.hasTag("Group:Four Horsemen") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = params.object,
            label = "+2",
            tooltip = "Bonus of Apocalypse",
            zoneguid = params.zoneguid,
            id = "apocalypse"})
    end
end

function setupMM()
    for i,o in pairs(city_zones_guids) do
        if i ~= 1 then
            local content = Global.Call('get_decks_and_cards_from_zone',o)
            if content[1] then
                for _,obj in pairs(content) do
                    if obj.hasTag("Group:Four Horsemen") then
                        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,label = "+2",tooltip = "Bonus of Apocalypse",id = "apocalypse"})
                        break
                    end
                end
            end
        end
    end
    
    function onObjectLeaveZone(zone,object)
        if object.getName() == "Pestilence" or object.getName() == "War" or object.getName() == "Famine" or object.getName() == "Death" then
            local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
            if escaped[1] and escaped[1].tag == "Deck" then
                local horsemen = {["Pestilence"] = 0,
                    ["War"] = 0,
                    ["Famine"] = 0,
                    ["Death"] = 0}
                for _,o in pairs(escaped[1].getObjects()) do
                    for _,tag in pairs(o.tags) do
                        if tag == "Group:Four Horsemen" then
                            horsemen[o.name] = 1
                            break
                        end
                    end
                end
                local c = 0
                for _,h in pairs(horsemen) do
                    c = c + h
                end
                if c == 4 then
                    broadcastToAll("The Four Horsemen have escaped! Evil Wins!")
                end
            end
        end
    end
end

function mmDefeated()
    for i,o in pairs(city_zones_guids) do
        if i ~= 1 then
            local content = Global.Call('get_decks_and_cards_from_zone',o)
            if content[1] then
                for _,c in pairs(content) do
                    if c.hasTag("Group:Four Horsemen") then
                        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = c, label = "", id = "apocalypse"})
                        break
                    end
                end
            end
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    broadcastToAll("Master Strike: Each player puts all cards costing more than 0 on top of their deck.")
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local toTop = {}
        local dest = getObjectFromGUID(drawguids[o.color]).getPosition()
        dest.y = dest.y + 2
        for _,obj in pairs(hand) do
            if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 0 then
                table.insert(toTop,obj)
            end
        end
        if toTop[1] then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = toTop,
                n = #toTop,
                pos = dest,
                flip = true,
                label = "Top",
                tooltip = "Put this card on top of your deck."})
            broadcastToColor(#toTop .. " cards in your hand were put on top of your deck. You may still rearrange them if you like.",o.color,o.color)
        end
    end
    return strikesresolved
end