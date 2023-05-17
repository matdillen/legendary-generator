function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    getObjectFromGUID(pushvillainsguid).Call('crossDimensionalRampage',"hulk")
    return strikesresolved
end
