function onLoad()
    mmname = "Spider-Queen"
    
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "mmZoneGUID",
        "escape_zone_guid"
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

function updateMMSpiderQueen()
    local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
    local bscount = 0
    if escaped[1] and escaped[1].tag == "Deck" then
        for _,o in pairs(escaped[1].getObjects()) do
            for _,k in pairs(o.tags) do
                if k == "Bystander" then
                    bscount = bscount + 1
                    break
                end
            end
        end
    elseif escaped[1] and escaped[1].hasTag("Bystander") then
        bscount = bscount + 1
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = bscount,
        label = "+" .. bscount,
        tooltip = "Spider-Queen gets +1 for each Bystander in the Escape pile.",
        f = 'updateMMSpiderQueen',
        f_owner = self})
end

function setupMM()
    updateMMSpiderQueen()
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMSpiderQueen,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMSpiderQueen,0.1)
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
                        if obj.name == "Spider-Infected" then
                            local pos = getObjectFromGUID(table.remove(emptycity,1)).getPosition()
                            vpilecontent[1].takeObject({position = pos,
                                guid = obj.guid,
                                smooth = true})
                            spiderinfound = true
                            broadcastToColor("Master Strike: Spider-infected henchmen added to first empty city space. You may move it to another empty one.",o.color,o.color)
                            break
                        end
                    end
                    if spiderinfound == false then
                        getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                    end
                elseif vpilecontent[1] then
                    if vpilecontent[1].getName() == "Spider-Infected" then
                        local pos = getObjectFromGUID(table.remove(emptycity,1)).getPosition()
                        vpilecontent[1].setPositionSmooth(pos)
                        broadcastToColor("Master Strike: Spider-infected henchmen added to first empty city space. You may move it to another empty one.",o.color,o.color)
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                    end
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                end
            end
        end
    else
        dealWounds()
    end
    return strikesresolved
end