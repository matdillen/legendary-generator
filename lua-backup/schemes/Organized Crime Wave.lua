function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function nonTwist(params)
    if params.obj.getName() == "Maggia Goons" then
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    end
    return 1
end

function setupCounter(init)
    if init then
        return {["name"] = "Maggia Goons",
                ["tooltip"] = "Maggia Goons escaped: __/5."}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            for _,o in pairs(escaped[1].getObjects()) do
                if o.name == "Maggia Goons" then
                    counter = counter + 1
                end
            end
        elseif escaped[1] and escaped[1].getName() == "Maggia Goons" then
            counter = counter + 1
        end
        return counter
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local city = params.city

    for _,o in pairs(city) do
        local citycards = Global.Call('get_decks_and_cards_from_zone',o)
        if citycards[1] then
            for _,object in pairs(citycards) do
                if object.getName() == "Maggia Goons" then
                    getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = citycards,
                        currentZone = getObjectFromGUID(o),
                        targetZone = getObjectFromGUID(escape_zone_guid),
                        enterscity = 0})
                    break
                end
            end
        end
    end
    local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
    local vildeckcurrentcount = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1].getQuantity()
    local goonsfound = 0
    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
            if vpilecontent[1] then
                if vpilecontent[1].getQuantity() > 1  then
                    local goonguids = {}
                    local vpileCards = vpilecontent[1].getObjects()
                    for j = 1, vpilecontent[1].getQuantity() do
                        if vpileCards[j].name == "Maggia Goons" then
                            table.insert(goonguids,vpileCards[j].guid)
                        end
                    end
                    goonsfound = goonsfound + #goonguids
                    if vpilecontent[1].getQuantity() ~= #goonguids then
                        for j = 1,#goonguids do
                            vpilecontent[1].takeObject({position=vildeckzone.getPosition(),
                                guid=goonguids[j],
                                flip=true})
                        end
                    else
                        vpilecontent[1].flip()
                        vpilecontent[1].setPositionSmooth(vildeckzone.getPosition())
                    end
                end
                if vpilecontent[1].getQuantity() == -1 then
                    if vpilecontent[1].getName() == "Maggia Goons" then
                        vpilecontent[1].flip()
                        vpilecontent[1].setPositionSmooth(vildeckzone.getPosition())
                        goonsfound = goonsfound + 1
                    end
                end
            end
        end
    end
    local goonsAdded = function()
        local test = vildeckcurrentcount + goonsfound
        local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
        if vildeck[1] and vildeck[1].getQuantity() == test then
            return true
        else
            return false
        end
    end
    local goonsShuffle = function()
        if goonsfound > 0 then
            local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
            vildeck[1].randomize()
        end
    end
    Wait.condition(goonsShuffle,goonsAdded)
    return twistsresolved
end