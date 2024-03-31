function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "drawguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver")
    for _,o in pairs(players) do
        local hand = o.getHandObjects()
        if hand[1] and #hand == 6 then
            broadcastToAll("Master Strike: Player " .. o.color .. " puts two cards from their hand on top of their deck.")
            local pos = getObjectFromGUID(drawguids[o.color]).getPosition()
            pos.y = pos.y + 2
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                n = 2,
                pos = pos,
                flip = true,
                label = "Top",
                tooltip = "Put on top of deck."})
        end
    end
    return strikesresolved
end