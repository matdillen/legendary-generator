function onLoad()
    mmname = "Authoritarian Iron Man"

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

function updateMMAuthoritarianIronMan()
    local bonus = ""
    if fortifiedCityZoneGUID then
        local citycontent = Global.Call('get_decks_and_cards_from_zone',fortifiedCityZoneGUID)
        for _,o in pairs(citycontent) do
            if o.hasTag("Villain") then
                bonus = "X"
                break
            end
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = 1,
        label = bonus,
        tooltip = "You can't fight Authoritarian Iron Man while there is a villain in the city space he fortifies.",
        f = 'updateMMAuthoritarianIronMan',
        id = "fortifiedbyvillain",
        f_owner = self})
end

function setupMM()
    function onObjectEnterZone(zone,object)
        if fortifiedCityZoneGUID and zone.guid == fortifiedCityZoneGUID then
            updateMMAuthoritarianIronMan()
        end
    end
    function onObjectLeaveZone(zone,object)
        if fortifiedCityZoneGUID and zone.guid == fortifiedCityZoneGUID then
            updateMMAuthoritarianIronMan()
        end
    end
end

function mmDefeated()
    local current_city = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
    for _,o in pairs(current_city) do
        getObjectFromGUID(o).Call('updateZonePower',{label = "",
            tooltip = "No longer fortified by Authoritarian Iron Man.",
            id = "authoritarianfortified"})
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local current_city = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
    local oldguid = fortifiedCityZoneGUID or nil
    if not current_city[#current_city-strikesresolved] then
        broadcastToAll("Master Strike: City too small for Authoritarian Iron Man to move!")
        return strikesresolved
    else
        fortifiedCityZoneGUID = current_city[#current_city-strikesresolved]
    end
    if oldguid then
        getObjectFromGUID(oldguid).Call('updateZonePower',{label = "",
            tooltip = "No longer fortified by Authoritarian Iron Man.",
            id = "authoritarianfortified"})
    end
    getObjectFromGUID(fortifiedCityZoneGUID).Call('updateZonePower',{label = "+3",
            tooltip = "Villains in the city space fortified by Authoritarian Iron Man get +3.",
            id = "authoritarianfortified"})
    return strikesresolved
end