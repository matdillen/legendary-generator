function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "woundszoneguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function setupCounter(init)
    if init then
        return {["zoneguid"] = woundszoneguid,
                ["tooltip"] = "Wound stack count: __."}
    else
        local woundsdeck = Global.Call('get_decks_and_cards_from_zone',woundszoneguid)[1]
        if woundsdeck then
            return math.abs(woundsdeck.getQuantity())
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    if twistsresolved < 3 then
        broadcastToAll("Scheme Twist: Nothing yet!")
    elseif twistsresolved < 7 then
        getObjectFromGUID(pushvillainsguid).Call('crossDimensionalRampage',"hulk")
    elseif twistsresolved < 11 then
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    end
    return twistsresolved
end