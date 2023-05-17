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

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait=6,
        prefix="Cost:",
        what="Cost"})
    for _,o in pairs(players) do
        local hand = o.getHandObjects()
        if #hand > 3 then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                n = #hand-3})
            broadcastToColor("Master Strike: Discard down to three cards.",o.color,o.color)
        end
    end
    return strikesresolved
end
