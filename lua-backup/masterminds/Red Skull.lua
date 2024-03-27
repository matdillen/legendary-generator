function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    for _,o in pairs(Player.getPlayers()) do
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
            pos = getObjectFromGUID(kopile_guid).getPosition(),
            label = "KO",
            tooltip = "KO this hero."})
    end
    broadcastToAll("Master Strike: Each player KOs a Hero from their hand.")
    return strikesresolved
end