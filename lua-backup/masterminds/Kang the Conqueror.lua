function onLoad()
    mmname = "Kang the Conqueror"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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

function updateMMKang()
    local kangcitycheck = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnTimeIncursions'))
    local villaincount = 0
    for _,o in pairs(kangcitycheck) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if obj.hasTag("Villain") then
                    villaincount = villaincount + 1
                    break
                end
            end
        end
    end
    local boost = 0
    if epicness then
        boost = 1
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = villaincount,
        label = "+" .. villaincount*(2+boost),
        tooltip = "Kang gets +" .. 2+boost .. " for each Villain in the city zones under a time incursion.",
        f = 'updateMMKang',
        id = "incursionconqueror",
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    function onObjectEnterZone(zone,object)
        updateMMKang()
    end
    function onObjectLeaveZone(zone,object)
        updateMMKang()
    end
end

function mmDefeated()
    local current_city = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
    for _,o in pairs(current_city) do
        getObjectFromGUID(o).Call('updateZonePower',{
            label = "",
            tooltip = "Villains under Kang's Time Incursions get nothing cause Kang is megadead.",
            id = "timeincursion"})
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    
    local kanglabel = "⌛"
    local kangboost = 2
    if epicness == true then
        kangboost = 3
    end
    local current_city = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
    if strikesresolved == 1 then
        timeIncursions = {current_city[2]}
        getObjectFromGUID(timeIncursions[1]).createButton({click_function='updatePower',
                    function_owner=getObjectFromGUID(pushvillainsguid),
                    position={0,0,0.5},
                    rotation={0,180,0},
                    label=kanglabel,
                    tooltip="This city space is under a Time Incursion.",
                    font_size=150,
                    font_color="Blue",
                    color={0,0,0,0.75},
                    width=250,height=250})
        getObjectFromGUID(timeIncursions[1]).Call('updateZonePower',{
            label = "+" .. kangboost,
            tooltip = "Villains under Kang's Time Incursions get +" .. kangboost .. ".",
            id = "timeincursion"})
    else
        for i=2,#current_city do
            local guidfound = false
            for _,o in pairs(timeIncursions) do
                if o == current_city[i] then
                    guidfound = true
                    break
                end
            end
            if guidfound == false then
                table.insert(timeIncursions,current_city[i])
                getObjectFromGUID(current_city[i]).createButton({click_function='updatePower',
                    function_owner=getObjectFromGUID(pushvillainsguid),
                    position={0,0,0.5},
                    rotation={0,180,0},
                    label=kanglabel,
                    tooltip="This city space is under a Time Incursion.",
                    font_size=150,
                    font_color="Blue",
                    color={0,0,0,0.75},
                    width=250,height=250})
                getObjectFromGUID(current_city[i]).Call('updateZonePower',{
                    label = "+" .. kangboost,
                    tooltip = "Villains under Kang's Time Incursions get +" .. kangboost .. ".",
                    id = "timeincursion"})
                break
            end
            if i == #current_city then
                broadcastToAll("Master Strike: But the whole city is under time incursions already!")
            end
        end
    end
    if epicness == true then
        for _,o in pairs(timeIncursions) do
            local content = Global.Call('get_decks_and_cards_from_zone',o)
            if content[1] then
                for _,p in pairs(content) do
                    if p.hasTag("Villain") then
                        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
                        broadcastToAll("Master Strike: There were villains under time incursion so Epic Kang wounds everyone!")
                        return strikesresolved
                    end
                end
            end
        end
    end
    return strikesresolved
end