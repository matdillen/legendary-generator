function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait="X-Men",prefix="Team:"})
    for _,o in pairs(players) do
        local hand = o.getHandObjects()
        if #hand > 4 then
            broadcastToAll("Master Strike: Player " .. o.color .. " discards down to 4 cards.")
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                n = #hand-4})
        end
    end
    return strikesresolved
end
