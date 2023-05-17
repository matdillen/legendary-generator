function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID"
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
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local officerdeck = getObjectFromGUID(officerDeckGUID)
    local pushOfficer = function(obj)
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = 3,
            tooltip = "This Officer is a villain. Gain it if you fight it."})
        obj.addTag("Villain")
        getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    end
    local takeOfficer = function()
        officerdeck.takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
            flip = true,
            smooth = true,
            callback_function = pushOfficer})
    end
    takeOfficer()
    Wait.time(takeOfficer,2)
    return strikesresolved
end
