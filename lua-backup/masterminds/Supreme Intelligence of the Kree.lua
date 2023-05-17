function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_discard"
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local mmloc = params.mmloc

    local mmcontent = Global.Call('get_decks_and_cards_from_zone',mmloc)
    local shards = 0
    for _,o in pairs(mmcontent) do
        if o.getName() == "Shard" then
            shards = o.Call('returnVal')
            break
        end
    end
    shards = shards + 1
    getObjectFromGUID(pushvillainsguid).Call('gainShard',{zoneGUID = mmloc})
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local posdiscard = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard)
        if hand[1] then
            for _,obj in pairs(hand) do
                local cost = hasTag2(obj,"Cost:")
                if cost and (cost == shards or cost == shards + 1) then
                    obj.setPosition(posdiscard)
                    broadcastToColor("Master Strike: " .. obj.getName() .. " discarded.",o.color,o.color)
                end
            end
        end
    end
    return strikesresolved
end
