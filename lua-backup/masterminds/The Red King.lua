function onLoad()
    mmname = "The Red King"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    mmZone = getObjectFromGUID(mmZoneGUID)
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function updateMMRedKing()
    local transformed = mmZone.Call('returnTransformed',mmname)
    if transformed == nil then
        return nil
    end
    local villainfound = 0
    local tooltip = "You can fight the Red King normally even if there any Villains are in the city."
    if transformed == false then
        tooltip = "You can't fight the Red King while any Villains are in the city."
        for _,o in pairs(city_zones_guids) do
            if o ~= city_zones_guids[1] then
                local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
                if citycontent[1] then
                    for _,p in pairs(citycontent) do
                        if p.hasTag("Villain") then
                           villainfound = villainfound + 1
                           break
                        end
                    end
                    if villainfound > 0 then
                        break
                    end
                end
            end
        end
        mmZone.Call('mmButtons',{mmname = mmname,
            checkvalue = 1,
            label = 7,
            tooltip = "Base power as written on the card.",
            f = 'updatePower',
            id = 'card'})
    elseif transformed == true then
        mmZone.Call('mmButtons',{mmname = mmname,
            checkvalue = 1,
            label = 10,
            tooltip = "Base power as written on the card.",
            f = 'updatePower',
            id = 'card'})
    end
    mmZone.Call('mmButtons',{mmname = mmname,
        checkvalue = villainfound,
        label = "X",
        tooltip = tooltip,
        f = 'updateMMRedKing',
        f_owner = self})
end

function setupMM()
    function onObjectEnterZone(zone,object)
        local transformed = mmZone.Call('returnTransformed',mmname)
        if transformed and transformed == false then
            updateMMRedKing()
        end
    end

    function onObjectLeaveZone(zone,object)
        local transformed = mmZone.Call('returnTransformed',mmname)
        if transformed and transformed == false then
            updateMMRedKing()
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local mmloc = params.mmloc

    local transformedPV = mmZone.Call('transformMM',getObjectFromGUID(mmloc))
    if transformedPV == true then
        local towound = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver")
        if towound[1] then
            for _,o in pairs(towound) do
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                broadcastToAll("Master Strike: Player " .. o.color .. " had no silver heroes and was wounded.")
            end
        end
    elseif transformedPV == false then
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    end
    return strikesresolved 
end
