function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "twistZoneGUID",
        "kopile_guid",
        "villainPileGUID",
        "setupGUID",
        "villainDeckZoneGUID",
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
    if params.obj.getName() == "Demon Bear" and params.targetZone.guid == escape_zone_guid then
        getObjectFromGUID(twistPileGUID).takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
            smooth=false})
            --this should be from the KO pile, but that is still a mess to sort out
            --take them from the scheme twist pile for now
        broadcastToAll("The Demon Bear escaped! Dream Horror!")
    end
    return params.obj
end

function extractBear(obj)
    for _,o in pairs(obj.getObjects()) do
        if o.name == "Demon Bear" then
            obj.takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
                flip=false,smooth=false,guid=o.guid})
            obj.setPositionSmooth(getObjectFromGUID(villainDeckZoneGUID).getPosition())
            break
        end
    end
    log("Demon Bear moved to twists pile. Other demons to villain deck.")
end

function setupSpecial(params)
    log("Taking the demon bear out.")
    local newSetupParts = table.clone(params.setupParts)
    newSetupParts[6] = params.setupParts[6]:gsub("Demons of Limbo|","")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = "Demons of Limbo",
        pileGUID = villainPileGUID,
        destGUID = topBoardGUIDs[1],
        callbackf = "extractBear",
        fsourceguid = self.guid})
    return {["setupParts"] = newSetupParts,
            ["villdeckc"] = 7}
end

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city
    local schemeParts = table.clone(params.schemeParts)

    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    --check if Bear is in the city
    for _,o in pairs(city) do
        local cityobjects = Global.Call('get_decks_and_cards_from_zone',o)
        if cityobjects[1] then
            for _,object in pairs(cityobjects) do
                if object.getName() == "Demon Bear" then
                    getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = cityobjects,
                        targetZone = getObjectFromGUID(escape_zone_guid),
                        enterscity = 0,
                        schemeParts = schemeParts})
                    broadcastToAll("Scheme Twist! Demon Bear escapes!",{1,0,0})
                    return nil
                end
            end
        end
    end
    --or his starting spot
    local cityobjects = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    if cityobjects[1] and cityobjects[1].getName() == "Demon Bear" then
        cityobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
        local bearMoved = function()
            local bear = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
            if bear[1] and bear[1].getName() == "Demon Bear" then
                return true
            else
                return false
            end
        end
        Wait.condition(click_push_villain_into_city,bearMoved)
        broadcastToAll("Scheme Twist! The Demon Bear entered the city.",{1,0,0})
        return nil
    end
    --or the escape pile
    local escapedobjects = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
    if escapedobjects[1] and escapedobjects[1].tag == "Deck" then
        for _,object in pairs(escapedobjects[1].getObjects()) do
            if object.name == "Demon Bear" then
                escapedobjects[1].takeObject({guid=object.guid,
                    position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    smooth=true,
                    callback_function = click_push_villain_into_city})
                broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from the escape pile.",{1,0,0})
                return nil
            end
        end
    elseif escapedobjects[1] and escapedobjects[1].tag == "Card" then
        if escapedobjects[1].getName() == "Demon Bear" then
            escapedobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
            local bearMoved = function()
                local bear = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
                if bear[1] and bear[1].getName() == "Demon Bear" then
                    return true
                else
                    return false
                end
            end
            Wait.condition(click_push_villain_into_city,bearMoved)
            broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from the escape pile.",{1,0,0})
            return nil
        end
    end
    --or the victory pile
    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            local vpobjects = Global.Call('get_decks_and_cards_from_zone',o)
            if vpobjects[1] and vpobjects[1].tag == "Deck" then
                for _,object in pairs(vpobjects[1].getObjects()) do
                    if object.name == "Demon Bear" then
                        vpobjects[1].takeObject({guid=object.guid,
                            position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                            smooth=true,
                            callback_function = click_push_villain_into_city})
                        broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from ".. i .. " player's victory pile.",{1,0,0})
                        for i2 = 1,4 do
                            getObjectFromGUID(pushvillainsguid).Call('getBystander',i)
                        end
                        return nil
                    end
                end
            elseif vpobjects[1] and vpobjects[1].tag == "Card" then
                if vpobjects[1].getName() == "Demon Bear" then
                    vpobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                    local bearMoved = function()
                        local bear = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
                        if bear[1] and bear[1].getName() == "Demon Bear" then
                            return true
                        else
                            return false
                        end
                    end
                    Wait.condition(click_push_villain_into_city,bearMoved)
                    broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from ".. i .. " player's victory pile.",{1,0,0})
                    for i2 = 1,4 do
                        getObjectFromGUID(pushvillainsguid).Call('getBystander',i)
                    end
                    return nil
                end
            end
        end
    end
    local kodobjects = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
    if kodobjects[1] and kodobjects[1].tag == "Deck" then
        for _,object in pairs(kodobjects[1].getObjects()) do
            if object.name == "Demon Bear" then
                kodobjects[1].takeObject({guid=object.guid,
                    position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    smooth=true,
                    callback_function = click_push_villain_into_city})

                broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from the KO pile.",{1,0,0})
                return nil
            end
        end
    elseif kodobjects[1] and kodobjects[1].tag == "Card" then
        if kodobjects[1].getName() == "Demon Bear" then
            kodobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
            local bearMoved = function()
                local bear = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
                if bear[1] and bear[1].getName() == "Demon Bear" then
                    return true
                else
                    return false
                end
            end
            Wait.condition(click_push_villain_into_city,bearMoved)
            broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from the KO pile.",{1,0,0})
            return nil
        end
    end
    --thor not found
    broadcastToAll("The Demon Bear not found? Where is he?")
    return nil
end
