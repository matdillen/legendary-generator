function onLoad()
    strikesstacked = 0
    local guids1 = {
        "pushvillainsguid",
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local cards = params.cards
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    if cards[1] then
        cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
        strikesstacked = strikesstacked + 1
    end
    local c = strikesstacked
    if epicness then
        c = strikesstacked + 1
    end
    for _,o in pairs(Player.getPlayers()) do
        getObjectFromGUID(pushvillainsguid).Call('wakingNightmare',{n = c,color = o.color})
    end
    broadcastToAll("Master Strike: Each player has " .. c .. " Waking Nightmares.")
    return nil
end
