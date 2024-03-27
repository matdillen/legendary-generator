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

    local players =  getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait="Marvel Knights",prefix="Team:"})
    for _,o in pairs(players) do
         getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
        broadcastToAll("Master Strike: Player " .. o.color .. " had no MK hero and was wounded.")
    end
    return strikesresolved
end