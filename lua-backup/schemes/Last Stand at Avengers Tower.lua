function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
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

function lastStandDrawNew(params)
    for i,zone in pairs(hqguids) do
        if i == params.index then
            getObjectFromGUID(zone).Call('click_draw_hero')
            break
        end
    end
end

function setupCounter(init)
    if init then
        return {["zoneguid"] = kopile_guid,
                ["tooltip"] = "KO'd nongrey heroes: __/13."}
    else 
        local escaped = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        if escaped[1] then
            local counter = 0
            for _,o in pairs(escaped) do
                if o.tag == "Deck" then
                    local escapees = Global.Call('hasTagD',{deck = o,tag = "HC:",find=true})
                    if escapees then
                        counter = counter + #escapees
                    end
                elseif hasTag2(o,"HC:") then
                    counter = counter + 1
                end
            end
            return counter
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    getObjectFromGUID(city_zones_guids[4]).Call('updateZonePower', {
        label = "+" .. twistsresolved,
        tooltip = "This villain gets +1 for each StarkTech Defense.",
        id = "starktech"
    })
    local citycards = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[4])
    if citycards[1] then
        for _,o in pairs(citycards) do
            if o.hasTag("Villain") then
                broadcastToAll("Scheme Twist: KO three Heroes from the HQ!",{1,0,0})
                local heroes = {}
                for _,obj in pairs(hqguids) do
                    local hero = getObjectFromGUID(obj).Call('getHeroUp')
                    if hero then
                        table.insert(heroes,hero)
                    else
                        broadcastToAll("Missing hero in the hq")
                        return nil
                    end
                end
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
                    hand = heroes,
                    n = 3,
                    pos = getObjectFromGUID(kopile_guid).getPosition(),
                    label = "KO",
                    tooltip = "KO this hero.",
                    trigger_function = 'lastStandDrawNew',
                    args = "self",
                    fsourceguid = self.guid})
                break
            end
        end
    end
    return nil
end