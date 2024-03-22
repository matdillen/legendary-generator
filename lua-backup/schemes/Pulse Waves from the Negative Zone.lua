function onLoad()   
    tax = 0

    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids2 = {
        "hqguids",
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function killButtons()
    local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
    Wait.condition(
        function()
            tax = 0
            for i,o in pairs(city_zones_guids) do
                if i ~~ 1 then
                    getObjectFromGUID(o).Call('updateZonePower',{label = "0",
                        tooltip = "This villain no longer gets anything from a pulse.",
                        id = "pulsewave"})
                end
            end
            for _,o in pairs(hqguids) do
                getObjectFromGUID(o).Call('editZoneBonus',{
                    id = "pulsewave",
                    value = 0,
                    tooltip = "This hero no longer gets anything from a pulse."
                })
            end
            local mmZone = getObjectFromGUID(mmZoneGUID)
            local masterminds = table.clone(mmZone.Call('returnVar',"masterminds"))
            for _,o in pairs(masterminds) do
                mmZone.Call('mmButtons',{mmname = o,
                    checkvalue = 1,
                    label = tostring(tax),
                    tooltip = "This mastermind no longer gets anything from a pulse.",
                    f = "mm",
                    id = "pulsewave"})
            end
        end,
        function()
            if Turns.turn_color == nextcolor then
                return true
            else
                return false
            end
        end)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 9 and twistsresolved % 2 == 1 then
        broadcastToColor("Scheme Twist: NEGATIVE PULSE This turn heroes in the HQ cost 1 less and villains/masterminds get -1!",Turns.turn_color,Turns.turn_color)
        tax = -1
        for i,o in pairs(city_zones_guids) do
            if i ~= 1 then
                getObjectFromGUID(o).Call('updateZonePower',{label = tostring(tax),
                    tooltip = "This villain gets -1 from a negative pulse.",
                    id = "pulsewave"})
            end
        end
        for _,o in pairs(hqguids) do
            getObjectFromGUID(o).Call('editZoneBonus',{
                id = "pulsewave",
                value = tax,
                tooltip = "This Hero costs 1 less due to a negative pulse."
            })
        end
        local mmZone = getObjectFromGUID(mmZoneGUID)
        local masterminds = table.clone(mmZone.Call('returnVar',"masterminds"))
        for _,o in pairs(masterminds) do
            mmZone.Call('mmButtons',{mmname = o,
                checkvalue = 1,
                label = tostring(tax),
                tooltip = "This mastermind gets -1 from a negative pulse.",
                f = "mm",
                id = "pulsewave"})
        end
        killButtons()
    elseif twistsresolved < 9 and twistsresolved % 2 == 0 then
        broadcastToColor("Scheme Twist: POSITIVE PULSE This turn heroes in the HQ cost 1 more and villains/masterminds get +1!",Turns.turn_color,Turns.turn_color) 
        tax = 1
        for i,o in pairs(city_zones_guids) do
            if i ~= 1 then
                getObjectFromGUID(o).Call('updateZonePower',{label = "+" .. tax,
                    tooltip = "This villain gets +1 from a positive pulse.",
                    id = "pulsewave"})
            end
        end
        for _,o in pairs(hqguids) do
            getObjectFromGUID(o).Call('editZoneBonus',{
                id = "pulsewave",
                value = "+" .. tax,
                tooltip = "This Hero costs 1 more due to a positive pulse."
            })
        end
        local mmZone = getObjectFromGUID(mmZoneGUID)
        local masterminds = table.clone(mmZone.Call('returnVar',"masterminds"))
        for _,o in pairs(masterminds) do
            mmZone.Call('mmButtons',{mmname = o,
                checkvalue = 1,
                label = "+" .. tax,
                tooltip = "This mastermind gets +1 from a positive pulse.",
                f = "mm",
                id = "pulsewave"})
        end
        killButtons()
    elseif twistsresolved == 9 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end