function onLoad()
    twistsstacked = 0

    tokenguid = "51bdc5"
    
    local guids1 = {
        "pushvillainsguid",
        "schemeZoneGUID",
        "escape_zone_guid",
        "mmZoneGUID",
        "twistPileGUID",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids2 = {
        "topBoardGUIDs",
        "city_topzones_guids",
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

function setupSpecial(params)
    log("Baby hope token moved above the scheme.")
    getObjectFromGUID(mmZoneGUID).Call('lockTopZone',topBoardGUIDs[2])
    local babyHope = getObjectFromGUID(tokenguid)
    babyHope.locked = false
    babyHope.setTags({"VP6","Baby Hope"})
    babyHope.setName("Baby Hope Token")
    babyHope.setPosition(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
end

function bonusInCity(params)
    local topzone = getObjectFromGUID(pushvillainsguid).Call('getCityZone',{top=true,guid=params.zoneguid})
    local content = Global.Call('get_decks_and_cards_from_zone',topzone)
    
    if content[1] then
        local babyfound = false
        for _,o in pairs(content) do
            if o.tag == "Deck" and Global.Call('hasTagD',{deck = o,tag = "Baby Hope"}) then
                babyfound = true
                break
            elseif o.tag == "Card" and o.getName() == "Baby Hope Token" then
                babyfound = true
                break
            end
        end
        if babyfound == true then
            getObjectFromGUID(pushvillainsguid).Call('powerButton',{label = "+4",
                zoneguid = params.zoneguid,
                tooltip = "Power bonus from holding Baby Hope.",
                id="babyhope"})
        end
    end
end

function cityShift(params)
    if params.obj.guid == tokenguid and params.targetZone.guid == escape_zone_guid then
        broadcastToAll("Baby Hope was taken away by a villain!", {r=1,g=0,b=0})
        getObjectFromGUID(twistPileGUID).takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition()})
        params.obj.setPosition(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
        return nil
    end
    return params.obj
end

function captureBaby(obj)
    local cityspaces = table.clone(city_zones_guids)
    local cardfound = false
    while cardfound == false do
        local cityobjects = Global.Call('get_decks_and_cards_from_zone',cityspaces[1])
        --locations don't count as villains, so they get skipped
        --locations may rarely capture bystanders. place these OUTSIDE the city or this will break
        local locationfound = false
        if cityobjects[1] and not cityobjects[2] then
            if cityobjects[1].getDescription():find("LOCATION") then
                locationfound = true
            end
        end
        --if no cards or only a location, check next city space
        if not cityobjects[1] or locationfound == true then
            table.remove(cityspaces,1)
        else
            --villain found, so put bystander here
            --this will break if something other than a villain or location is on its own in the city
            cardfound = true
            local targetZone = getObjectFromGUID(cityspaces[1])
            getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{
                objects = {obj},
                currentZone = getObjectFromGUID(cityspaces[1]),
                targetZone = targetZone,
                enterscity = 1})
            Wait.condition(
                function()
                    getObjectFromGUID(cityspaces[1]).Call('updatePower')
                end,
                function()
                    local hopevillain = Global.Call('get_decks_and_cards_from_zone',cityspaces[1])
                    for _,o in pairs(hopevillain) do
                        if o.guid == tokenguid then
                            return true
                        end
                    end
                    return false
                end
            )
        end
        if not cityspaces[1] then
            --if the city is empty:
            cardfound = true
            obj.setPositionSmooth(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
        end
    end
end

function setupCounter(init)
    if init then
        return {["zoneguid"] = twistZoneGUID,
                ["tooltip"] = "Baby captured: __/3."}
    else
        local moralfailings = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
        if moralfailings then
            return math.abs(moralfailings.getQuantity())
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    local city = params.city
    local babyfound = false
    for _,o in pairs(city_topzones_guids) do
        local cityobjects = Global.Call('get_decks_and_cards_from_zone',o)
        if cityobjects[1] then
            for _,object in pairs(cityobjects) do
                if object.guid == tokenguid then
                    babyfound = true
                    object.setPosition(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
                end
            end
            if babyfound == true then
                broadcastToAll("Villain with Baby Hope escaped!",{r=1,g=0,b=0})
                local cityzone = getObjectFromGUID(pushvillainsguid).Call('getCityZone',{guid = o,
                    top = false})
                local cityobjects2 = Global.Call('get_decks_and_cards_from_zone',cityzone)
                getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{
                    objects = cityobjects2,
                    currentZone = getObjectFromGUID(o),
                    targetZone = getObjectFromGUID(escape_zone_guid),
                    enterscity = 0})
                getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
                break
            end
        end
    end
    if babyfound == false then
        local babyHope = getObjectFromGUID(tokenguid)
        if babyHope then
            captureBaby(babyHope)
        else
            for i,o in pairs(vpileguids) do
                local vpile = Global.Call('get_decks_and_cards_from_zone',o)[1]
                if vpile and vpile.tag == "Card" and vpile.guid == tokenguid then
                    captureBaby(vpile)
                    break
                elseif vpile then
                    local vpilecontent = vpile.getObjects()
                    local pos = vpile.getPosition()
                    pos.y = pos.y + 2
                    for _,c in pairs(vpilecontent) do
                        if c.guid == tokenguid then
                            vpile.takeObject({position = pos,
                                guid = tokenguid,
                                flip = false,
                                smooth = false,
                                callback_function = captureBaby})
                            break
                        end
                    end
                end
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    end
    return nil
end