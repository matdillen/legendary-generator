function onLoad()   
    hydrahailed = false
    shieldhailed = false
    
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids",
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function forhydra()
    for _,o in pairs(hqguids) do
        getObjectFromGUID(o).Call('toggleButton')
    end
end

function forshield()
    for i = 1,#city_zones_guids do
        if i ~= 1 then
            getObjectFromGUID(city_zones_guids[i]).Call('toggleButton')
        end
    end
end

function hailhydra(params)
    if params.id == "shield" and shieldhailed == false then
        shieldhailed = true
        forshield()
        broadcastToColor("You will never abandon S.H.I.E.L.D.! You cannot fight villains or masterminds this turn.",Turns.turn_color,Turns.turn_color)
        local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
        Wait.condition(forshield,
            function()
                if Turns.turn_color == nextcolor then
                    shieldhailed = false
                    return true
                else
                    return false
                end
            end)
    elseif params.id == "hydra" and hydrahailed == false then
        hydrahailed = true
        forhydra()
        broadcastToColor("Hail HYDRA! You cannot recruit heroes this turn. A villain captures a bystander.",Turns.turn_color,Turns.turn_color)
        local villains = {}
        for _,o in pairs(city_zones_guids) do
            local content = Global.Call('get_decks_and_cards_from_zone',o)
            for _,obj in pairs(content) do
                if obj.hasTag("Villain") then
                    table.insert(villains,obj)
                    break
                end
            end
        end
        if villains[2] then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
                hand = villains,
                label = "Captures",
                pos = "Stay",
                tooltip = "This villain captures a bystander.",
                trigger_function = 'capturesBystander',
                args = "self"})
        elseif villains[1] then
            getObjectFromGUID(pushvillainsguid).Call('capturesBystander',villains[1])
        end
        local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
        Wait.condition(forhydra,
            function()
                if Turns.turn_color == nextcolor then
                    hydrahailed = false
                    return true
                else
                    return false
                end
            end)
    end
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Twists resolved: __/10."}
    else
        return getObjectFromGUID(pushvillainsguid).Call('returnVar',"twistsresolved")
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    getObjectFromGUID(pushvillainsguid).Call('offerChoice',{color = Turns.turn_color,
        choices = {["shield"] = "S.H.I.E.L.D.",
            ["hydra"] = "HYDRA"},
        fsourceguid = self.guid,
        resolve_function = 'hailhydra',
        choicecolors = {["shield"] = "Red",
            ["hydra"] = "White"}})
    return twistsresolved
end