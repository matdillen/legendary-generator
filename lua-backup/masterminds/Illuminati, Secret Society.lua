function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function table.clone(org,key)
    if key then
        local new = {}
        for i,o in pairs(org) do
            new[i] = o
        end
        return new
    else
        return {table.unpack(org)}
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local mmloc = params.mmloc

    local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmloc))
    if transformedPV == true then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local toDiscard = {}
            for _,obj in pairs(hand) do
                if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 1 and hasTag2(obj,"Cost:") < 4 then
                    table.insert(toDiscard,obj)
                end
            end
            if hand[1] then
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = toDiscard,
                    n = 2})
            end
        end
        broadcastToAll("Master Strike: Each player reveals their hand and discards two cards that each cost between 1 and 4.")
    elseif transformedPV == false then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local toDiscard = {}
            for _,obj in pairs(hand) do
                if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 5 and hasTag2(obj,"Cost:") < 8 then
                    table.insert(toDiscard,obj)
                end
            end
            if hand[1] then
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = toDiscard,
                    n = 2})
            end
        end
        broadcastToAll("Master Strike: Each player reveals their hand and discards two cards that each cost between 5 and 8.")
    end
    return strikesresolved
end
