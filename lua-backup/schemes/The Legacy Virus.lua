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

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver")
    for _,o in pairs(players) do
        getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
        broadcastToAll("Scheme Twist. Player " .. o.color .. " got a wound!")
    end
    return twistsresolved
end