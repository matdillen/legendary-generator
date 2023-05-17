function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "setupGUID"
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
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    local dominated = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    if dominated[1] then
        getObjectFromGUID(pushvillainsguid).Call('koCard',dominated[1])
    end
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local toKO = {}
        for _,obj in pairs(hand) do
            if hasTag2(obj,"HC:") then
                table.insert(toKO,obj)
            end
        end
        if toKO[1] then
            if epicness then
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = toKO,
                    n = 2,
                    pos = getObjectFromGUID(strikeloc).getPosition(),
                    label = "Dominate",
                    tooltip = "Onslaught dominates this hero."})
                broadcastToColor("Master Strike: Two nongrey heroes from your hand become dominated by Onslaught.",o.color,o.color)
            else
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = toKO,
                    pos = getObjectFromGUID(strikeloc).getPosition(),
                    label = "Dominate",
                    tooltip = "Onslaught dominates this hero."})
                broadcastToColor("Master Strike: A nongrey hero from your hand becomes dominated by Onslaught.",o.color,o.color)
            end
        end
    end
    if epicness then
        getObjectFromGUID(setupGUID).Call('playHorror')
    end
    return strikesresolved
end
