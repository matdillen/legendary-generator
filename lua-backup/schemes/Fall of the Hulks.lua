function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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