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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local strikeloc = params.strikeloc

    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local toBound = {}
        for _,obj in pairs(hand) do
            if hasTag2(obj,"HC:") then
                table.insert(toBound,obj)
            end
        end
        if toBound[1] then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = toBound,
                pos = getObjectFromGUID(strikeloc).getPosition(),
                label = "Bind",
                tooltip = "Thanos binds this soul. You're unlikely to ever see it back again."})
            broadcastToColor("Master Strike: A nongrey hero from your hand becomes a soul bound by Thanos.",o.color,o.color)
        end
    end
    return strikesresolved
end
