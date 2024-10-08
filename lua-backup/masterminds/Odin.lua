function onLoad()
    mmname = "Odin"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "escape_zone_guid"
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

function updateMMOdin()
    local shiarfound = 0
    for i=2,#city_zones_guids do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[i])
        if citycontent[1] then
            for _,o in pairs(citycontent) do
                if o.getName():find("Asgardian Warriors") then
                    shiarfound = shiarfound + 1
                    break
                end
            end
        end
    end
    local escapezonecontent = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
    if escapezonecontent[1] and escapezonecontent[1].tag == "Deck" then
        for _,o in pairs(escapezonecontent[1].getObjects()) do
            if o.name == "Asgardian Warriors" then
                shiarfound = shiarfound + 1
            end
        end
    elseif escapezonecontent[1] then
        if escapezonecontent[1].getName() == "Asgardian Warriors" then
            shiarfound = shiarfound + 1
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = shiarfound,
        label = "+" .. shiarfound,
        tooltip = "Odin gets +1 for each Asgardian Warrior in the city and Escape Pile.",
        id = "odinsbonus",
        f = 'updateMMOdin',
        f_owner = self})
end

function setupMM()
    updateMMOdin()
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMOdin,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMOdin,0.1)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local city = params.city

    local emptycity = table.clone(city)
    local iter = 0
    for i,o in ipairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if obj.hasTag("Villain") then
                    table.remove(emptycity,i-iter)
                    iter = iter + 1
                    break
                end
            end
        end
    end
    if emptycity[1] then
        for _,o in pairs(Player.getPlayers()) do
            if not emptycity[1] then
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
            else
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    local spiderinfound = false
                    for _,obj in pairs(vpilecontent[1].getObjects()) do
                        if obj.name == "Asgardian Warriors" then
                            local pos = getObjectFromGUID(table.remove(emptycity,1)).getPosition()
                            vpilecontent[1].takeObject({position = pos,
                                guid = obj.guid,
                                smooth = true})
                            spiderinfound = true
                            broadcastToColor("Master Strike: Asgardian Warriors henchmen added to first empty city space. You may move it to another empty one.",o.color,o.color)
                            break
                        end
                    end
                    if spiderinfound == false then
                        getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                    end
                elseif vpilecontent[1] then
                    if vpilecontent[1].getName() == "Asgardian Warriors" then
                        local pos = getObjectFromGUID(table.remove(emptycity,1)).getPosition()
                        vpilecontent[1].setPositionSmooth(pos)
                        broadcastToColor("Master Strike: Asgardian Warriors henchmen added to first empty city space. You may move it to another empty one.",o.color,o.color)
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                    end
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                end
            end
        end
    else
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    end
    return strikesresolved
end