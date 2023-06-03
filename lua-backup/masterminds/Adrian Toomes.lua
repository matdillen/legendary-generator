function onLoad()
    mmname = "Adrian Toomes"
    
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMAdrian()
    local strikes = getObjectFromGUID(pushvillainsguid).Call('returnVar','strikesresolved')
    local boost = strikes*2
    if epicness then
        boost = strikes*3
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = strikes,
        label = "+" .. boost,
        tooltip = "Adrian Toomes is a double (or triple) striker and gets +" .. boost/strikes .. " for each Master Strike that has been played.",
        f = 'updateMMAdrian',
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    updateMMAdrian()
    
    function onObjectEnterZone(zone,object)
        if object.getName() == "Masterstrike" then
            updateMMAdrian()
        end
    end
end

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city
    local mmname = params.mmname
    local epicness = params.epicness
    local mmloc = params.mmloc
    local strikeloc = params.strikeloc

    broadcastToAll("Master Strike: " .. mmname .. " wasn't scripted yet.")
    return nil
end
