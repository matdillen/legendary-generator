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

    local towound = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Green")
    for _,o in pairs(towound) do
        getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
        broadcastToAll("Master Strike: Player " .. o.color .. " had no green heroes and was wounded.")
    end
    return strikesresolved
end