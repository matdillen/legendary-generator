function onLoad()
    reaperbonus = 0
    
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function resolveStrike(params)
    local cards = params.cards
    local city = params.city
    local epicness = params.epicness

    if cards[1] then
        reaperbonus = 0
        if epicness then
            reaperbonus = 1
            local locationcount = 0
            for _,o in pairs(city) do
                local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
                if citycontent[1] then
                    for _,p in pairs(citycontent) do
                        if p.getDescription():find("LOCATION") then
                            locationcount = locationcount + 1
                            break
                        end
                    end
                end
            end
            if locationcount > 1 then
                getObjectFromGUID(pushvillainsguid).Call('dealWounds')
            end
        end
        cards[1].setName("Graveyard")
        cards[1].setDescription("LOCATION: Put this above the City Space closest to the Villain Deck and without a Location already. Can be fought, but does not count as a Villain. KO the weakest Location if the City is already full of Locations.")
        cards[1].addTag("VP" .. 5 + reaperbonus)
        cards[1].addTag("Power:" .. 7 + reaperbonus)
        cards[1].addTag("Location")
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
            label = 7 + reaperbonus,
            tooltip = "This strike is a Graveyard Location."})
        getObjectFromGUID(pushvillainsguid).Call('push_all',table.clone(city))
    else
        broadcastToAll("No Master Strike found, so Grim Reaper failed to manifest a Graveyard.")
    end
    return nil
end
