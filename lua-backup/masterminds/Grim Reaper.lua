function onLoad()
    reaperbonus = 0
    mmname = "Grim Reaper"
    
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
    if params.object.getName() == "Graveyard" and params.object.hasTag("Location") then
        local cityobjects = Global.Call('get_decks_and_cards_from_zone',params.zoneguid)
        for _,obj in pairs(cityobjects) do
            if obj.hasTag("Villain") then
                getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object, 
                    label = "+" .. 2, 
                    id = "villainPresent",
                    tooltip = "Graveyard gets +2 if there's a villain there.",
                    zoneguid = params.zoneguid})
                return nil
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object, 
            label = "",
            id = "villainPresent",
            tooltip = "Graveyard does not get +2 if there's no villain there.",
            zoneguid = params.zoneguid})
    end
end

function updateMMReaper()
    local locationcount = 0
    for _,o in pairs(city_zones_guids) do
        if o ~= city_zones_guids[1] then
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if obj.getDescription():find("LOCATION") then
                        locationcount = locationcount + 1
                        break
                    end
                end
            end
        end
    end
    local locationcount2 = locationcount
    if epicness then
        locationcount2 = locationcount*2
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = locationcount2,
        label = "+" .. locationcount2,
        tooltip = "Grim Reaper gets +" .. locationcount2/locationcount .. " for each Location card in the city.",
        f = 'updateMMReaper',
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    updateMMReaper()
    function onObjectEnterZone(zone,object)
        if object.getDescription():find("LOCATION") then
            updateMMReaper()
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.getDescription():find("LOCATION") then
            updateMMReaper()
        end
    end
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
        getObjectFromGUID(pushvillainsguid).Call('push_all',table.clone(city))
    else
        broadcastToAll("No Master Strike found, so Grim Reaper failed to manifest a Graveyard.")
    end
    return nil
end
