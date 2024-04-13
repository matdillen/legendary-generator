function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "twistZoneGUID",
        "kopile_guid",
        "setupGUID",
        "villainPileGUID",
        "twistPileGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids",
        "topBoardGUIDs"
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
    
    getObjectFromGUID(setupGUID).Call('invertCity')
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
    if params.obj.getName() == "Thor" and params.targetZone.guid == escape_zone_guid then
        getObjectFromGUID(twistPileGUID).takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
            smooth=false})
            --this should be from the KO pile, but that is still a mess to sort out
            --take them from the scheme twist pile for now
        broadcastToAll("Thor escaped! Triumph of Asgard!")
    end
    return params.obj
end

function onlyThor(obj)
    for _,o in pairs(obj.getObjects()) do
        if o.name == "Thor" then
            obj.takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
                flip=false,
                smooth=false,
                guid=o.guid})
            obj.destruct()
            break
        end
    end
    log("Thor moved to twists zone.")
end

function setupSpecial(params)
    log("Add extra Avengers villain group, but keep only Thor.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = "Avengers",
        pileGUID = villainPileGUID,
        destGUID = topBoardGUIDs[1],
        callbackf = "onlyThor",
        fsourceguid = self.guid})
end

function thorsEntourage(message)
    Wait.time(function() 
            getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city') 
        end,1)
    Wait.time(function()
        for i=1,3 do
            getObjectFromGUID(pushvillainsguid).Call('addBystanders',city_zones_guids[2])
        end
    end,1.5)
    broadcastToAll(message,{1,0,0})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local city = params.city
    --check if Thor is in the city
    for _,o in pairs(city) do
        local cityobjects = Global.Call('get_decks_and_cards_from_zone',o)
        if cityobjects[1] then
            for _,object in pairs(cityobjects) do
                if object.getName() == "Thor" then
                    getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = table.clone(cityobjects),
                        targetZone = getObjectFromGUID(escape_zone_guid),
                        enterscity = 0,
                        schemeParts = {self.getName()}})
                    broadcastToAll("Scheme Twist! Thor escapes!",{1,0,0})
                    return twistsresolved
                end
            end
        end
    end
    --or his starting spot
    local cityobjects = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    if cityobjects[1] and cityobjects[1].tag == "Card" and cityobjects[1].getName() == "Thor" then
        cityobjects[1].setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
        thorsEntourage("Scheme Twist! Thor entered the city.")
        return twistsresolved
    elseif cityobjects[1] and cityobjects[1].tag == "Deck" then
        for _,o in pairs(cityobjects[1].getObjects()) do
            if o.name == "Thor" then
                cityobjects[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    guid = o.guid,
                    smooth = true})
                thorsEntourage("Scheme Twist! Thor entered the city.")
                return twistsresolved
            end
        end
    end
    --or the escape pile
    local escapedobjects = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
    if escapedobjects[1] and escapedobjects[1].tag == "Deck" then
        for _,object in pairs(escapedobjects[1].getObjects()) do
            if object.name == "Thor" then
                escapedobjects[1].takeObject({guid=object.guid,
                    position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    smooth=true})
                thorsEntourage("Scheme Twist! Thor re-entered the city from the escape pile.")
                return twistsresolved
            end
        end
    elseif escapedobjects[1] and escapedobjects[1].tag == "Card" then
        if escapedobjects[1].getName() == "Thor" then
            escapedobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
            thorsEntourage("Scheme Twist! Thor re-entered the city from the escape pile.")
            return twistsresolved
        end
    end
    --or the victory pile
    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            local vpobjects = Global.Call('get_decks_and_cards_from_zone',o)
            if vpobjects[1] and vpobjects[1].tag == "Deck" then
                for _,object in pairs(vpobjects[1].getObjects()) do
                    if object.name == "Thor" then
                        vpobjects[1].takeObject({guid=object.guid,
                            position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                            smooth=true})
                        thorsEntourage("Scheme Twist! Thor re-entered the city from ".. i .. " player's victory pile.")
                        return twistsresolved
                    end
                end
            elseif vpobjects[1] and vpobjects[1].tag == "Card" then
                if vpobjects[1].getName() == "Thor" then
                    vpobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                    thorsEntourage("Scheme Twist! Thor re-entered the city from ".. i .. " player's victory pile.")
                    return twistsresolved
                end
            end
        end
    end
    local kodobjects = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
    if kodobjects[1] and kodobjects[1].tag == "Deck" then
        for _,object in pairs(kodobjects[1].getObjects()) do
            if object.name == "Thor" then
                kodobjects[1].takeObject({guid=object.guid,
                    position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    smooth=true})
                thorsEntourage("Scheme Twist! Thor re-entered the city from the KO pile.")
                return twistsresolved
            end
        end
    elseif kodobjects[1] and kodobjects[1].tag == "Card" then
        if kodobjects[1].getName() == "Thor" then
            kodobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
            thorsEntourage("Scheme Twist! Thor re-entered the city from the KO pile.")
            return twistsresolved
        end
    end
    --thor not found
    broadcastToAll("Thor not found? Where is he?")
    return nil
end