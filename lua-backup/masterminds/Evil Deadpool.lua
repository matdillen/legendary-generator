function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function evildeadpool(params)
    evilDeadpoolStrike[params.color] = hasTag2(params.obj,"Cost:") or 0
    evilDeadpoolCounter = evilDeadpoolCounter + 1
    evilDeadpoolValue = math.min(evilDeadpoolValue,evilDeadpoolStrike[params.color])
    if evilDeadpoolCounter == #Player.getPlayers() then
        for i,p in pairs(evilDeadpoolStrike) do
            if p == evilDeadpoolValue then
                getObjectFromGUID(pushvillainsguid).Call('getWound',i)
            end
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    evilDeadpoolStrike = {}
    evilDeadpoolCounter = 0
    evilDeadpoolValue = 20
    broadcastToAll("Master Strike: Each player simultaneously discards a card. Whoever discards the lowest-costing card (or tied for lowest) gains a Wound.")
    for _,o in pairs(Player.getPlayers()) do
        
        if #o.getHandObjects() == 0 then
            evilDeadpoolCounter = evilDeadpoolCounter +1
        else
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                trigger_function = 'evildeadpool',
                args = "self",
                fsourceguid = self.guid})
        end
    end
    return strikesresolved
end
