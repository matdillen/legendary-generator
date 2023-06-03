function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids",
        "hqguids"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function nonTwist(params)
    local obj = params.obj
    
    if hasTag2(obj,"Cost:") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = hasTag2(obj,"Cost:")+2,
            tooltip = "This hero is a Skrull Shapeshifter and has power equal to its cost +2. Gain it if you fight it."})
        obj.addTag("Villain")
    end
    return 1
end

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function drawNew(params)
    getObjectFromGUID(hqguids[params.index]).Call('click_draw_hero')
    local heroMoved = function()
        local entercard = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
        if entercard[1] and entercard[1].guid == params.obj.guid then
            return true
        else
            return false
        end
    end
    Wait.condition(click_push_villain_into_city,heroMoved)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    local cost = 0
    local highestguid = {}
    local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and hasTag2(hero,"Cost:") > cost then
            cost = hasTag2(hero,"Cost:")
            highestguid = {[i] = hero}
        elseif hero and hasTag2(hero,"Cost:") == cost then
            highestguid[i] = hero
        end
    end
    local count = 0
    for _,o in pairs(highestguid) do
        count = count + 1
    end
    if count > 1 then
        broadcastToAll("Choose one of the highest cost heroes in the HQ to enter the city as a Skrull Villain.")
        promptDiscard({color = Turns.turn_color,
            hand = highestguid,
            pos = pos,
            label = "Push",
            tooltip = "Push this hero into the city as a Skrull Villain.",
            trigger_function = 'drawNew',
            args = "self",
            fsourceguid = self.guid})
    else
        for i,o in pairs(highestguid) do
            o.setPositionSmooth(pos)
            getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
            local heroMoved = function()
                local entercard = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
                if entercard[1] and entercard[1].guid == o.guid then
                    return true
                else
                    return false
                end
            end
            Wait.condition(click_push_villain_into_city,heroMoved)
        end
    end
    return nil
end
