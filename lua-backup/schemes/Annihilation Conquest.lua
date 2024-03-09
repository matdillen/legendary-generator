function onLoad()
    twistsstacked = 0
    
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids",
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function bonusInCity(params)
    if params.object.hasTag("Phalanx-Infected") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object,
        label = "+" .. math.floor(params.twistsstacked/2),
        zoneguid = params.zoneguid,
        id = "conquests",
        tooltip = "This Phalanx-Infected villain gets +1 for each two twists stacked as conquests."})
    end
end

function processPhalanxInfected(params) 
    local obj = params.obj
    local index = params.index
    
    obj.addTag("Villain")
    obj.addTag("Phalanx-Infected")
    obj.addTag("Power:" .. hasTag2(obj,"Cost:"))
    getObjectFromGUID(hqguids[index]).Call('click_draw_hero')
    Wait.condition(
        function() 
            getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city') 
        end,
        function()
            local hero = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
            if hero[1] and hero[1].guid == obj.guid then
                return true
            else
                return false
            end
        end)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    
    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    local candidate = {}
    local cost = 0
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            if hasTag2(hero,"Cost:") and hasTag2(hero,"Cost:") > cost then
                candidate = {}
                cost = hasTag2(hero,"Cost:")
                candidate[i] = hero
            elseif hasTag2(hero,"Cost:") and hasTag2(hero,"Cost:") == cost then
                candidate[i] = hero
            end
        else
            printToAll("Missing hero in HQ!!")
            return nil
        end
    end
    local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
    pos.y = pos.y + 3
    local candn = 0
    for _,o in pairs(candidate) do
        candn = candn + 1
    end
    if candn > 1 then
        broadcastToAll("Scheme Twist: Choose one of the tied highest cost heroes in the HQ to enter the city as a villain.")
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = candidate,
            pos = pos,
            label = "Push",
            tooltip = "Push this hero into the city as a Phalanx-Infected villain.",
            trigger_function = 'processPhalanxInfected',
            args = "self",
            fsourceguid = self.guid})
    elseif candn == 1 then
        local zoneguid = nil
        local hero = nil
        for i,o in pairs(candidate) do
            zoneguid = i
            hero = o
        end
        hero.setPositionSmooth(pos)
        processPhalanxInfected({obj = hero,
            index = zoneguid})
    else
        broadcastToAll("No heroes found?")
        return nil
    end
    return nil
end