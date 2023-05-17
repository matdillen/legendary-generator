function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_draw"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "playerBoards"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local playercolors = Player.getPlayers()
    broadcastToAll("Master Strike: Each player puts all cards costing more than 0 on top of their deck.")
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local toTop = {}
        local dest = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_draw)
        dest.y = dest.y + 2
        for _,obj in pairs(hand) do
            if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 0 then
                table.insert(toTop,obj)
            end
        end
        if toTop[1] then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = toTop,
                n = #toTop,
                pos = dest,
                flip = true,
                label = "Top",
                tooltip = "Put this card on top of your deck."})
            broadcastToColor(#toTop .. " cards in your hand were put on top of your deck. You may still rearrange them if you like.",o.color,o.color)
        end
    end
    return strikesresolved
end
