function onLoad()
    twistsstacked = 0
    
    local guids1 = {
        "pushvillainsguid",
        "schemeZoneGUID",
        "escape_zone_guid"
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    local city = params.city
    local babyfound = false
    for _,o in pairs(city) do
        local cityobjects = getObjectFromGUID(o).getObjects()
        if cityobjects[1] then
            for _,object in pairs(cityobjects) do
                if object.getName() == "Baby Hope Token" then
                    babyfound = true
                    object.setPosition(getObjectFromGUID(schemeZoneGUID).getPosition())
                end
            end
            if babyfound == true then
                broadcastToAll("Villain with Baby Hope escaped!",{r=1,g=0,b=0})
                cityobjects = Global.Call('get_decks_and_cards_from_zone',o)
                getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{
                    objects = table.clone(cityobjects),
                    targetZone = getObjectFromGUID(escape_zone_guid),
                    enterscity = 0,
                    schemeParts = {"Capture Baby Hope"}})
                getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
                break
            end
        end
    end
    if babyfound == false then
        local babyHope = getObjectFromGUID("e27f77")
        local cityspaces = table.clone(city)
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
                    objects = {babyHope},
                    targetZone = targetZone,
                    enterscity = 1})
                Wait.condition(
                    function()
                        getObjectFromGUID(cityspaces[1]).Call('updatePower')
                    end,
                    function()
                        local hopevillain = Global.Call('get_decks_and_cards_from_zone',cityspaces[1])
                        for _,o in pairs(hopevillain) do
                            if o.getName() == "Baby Hope Token" then
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
                babyHope.setPositionSmooth(getObjectFromGUID(schemeZoneGUID).getPosition())
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    end
    return nil
end