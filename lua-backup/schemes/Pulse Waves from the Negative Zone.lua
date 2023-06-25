function onLoad()   
    tax = 0

    local guids1 = {
        "pushvillainsguid"
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

function heroTax()
    return tax
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
                local zone = getObjectFromGUID(o)
                for i,b in pairs(zone.getButtons()) do
                    if b.click_function == "heroTax" then
                        zone.removeButton(i-1)
                        break
                    end
                end
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
        for i,o in pairs(city_zones_guids) do
            if i ~= 1 then
                getObjectFromGUID(o).Call('updateZonePower',{label = "-1",
                    tooltip = "This villain gets -1 from a negative pulse.",
                    id = "pulsewave"})
            end
        end
        tax = -1
        for _,o in pairs(hqguids) do
            local buttonfound = false
            for i,b in pairs(getObjectFromGUID(o).getButtons()) do
                if b.click_function == "heroTax" then
                    getObjectFromGUID(o).editButton({index = i-1,
                        label = "-1",
                        tooltip = "This Hero costs 1 less due to a negative pulse."})
                    buttonfound = true
                    break
                end
            end
            if not buttonfound then
                getObjectFromGUID(o).createButton({click_function='heroTax',
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    scale = {1,1,0.5},
                    label="-1",
                    tooltip="This Hero costs 1 less due to a negative pulse.",
                    font_size=300,
                    font_color="Yellow",
                    color={0,0,0,0.75},
                    width=250,height=150})
            end
        end
        killButtons()
    elseif twistsresolved < 9 and twistsresolved % 2 == 0 then
        broadcastToColor("Scheme Twist: POSITIVE PULSE This turn heroes in the HQ cost 1 more and villains/masterminds get +1!",Turns.turn_color,Turns.turn_color) 
        for i,o in pairs(city_zones_guids) do
            if i ~= 1 then
                getObjectFromGUID(o).Call('updateZonePower',{label = "+1",
                    tooltip = "This villain gets +1 from a positive pulse.",
                    id = "pulsewave"})
            end
        end
        tax = 1
        for _,o in pairs(hqguids) do
            local buttonfound = false
            for i,b in pairs(getObjectFromGUID(o).getButtons()) do
                if b.click_function == "heroTax" then
                    getObjectFromGUID(o).editButton({index = i-1,
                        label = "+1",
                        tooltip = "This Hero costs 1 more due to a positive pulse."})
                    buttonfound = true
                    break
                end
            end
            if not buttonfound then
                getObjectFromGUID(o).createButton({click_function='heroTax',
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    scale = {1,1,0.5},
                    label="+1",
                    tooltip="This Hero costs 1 more due to a positive pulse.",
                    font_size=300,
                    font_color="Yellow",
                    color={0,0,0,0.75},
                    width=250,height=150})
            end
        end
        killButtons()
    elseif twistsresolved == 9 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end