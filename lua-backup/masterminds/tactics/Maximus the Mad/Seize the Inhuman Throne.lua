function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function tacticEffect(params)
    local thronesfavor = getObjectFromGUID(setupGUID).Call('returnVar',"thronesfavor")
    local val = 4
    if thronesfavor == "mmMaximus the Mad" then
        val = 3
    end
    getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",
        player_clicker_color = "mmMaximus the Mad"})
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        --log(o.color)
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,n = #hand-val})
    end
    broadcastToAll("Maximus Fight effect: Maximus seizes the inhuman throne! Each player discards down to " .. val .. " cards.")
end