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
    local cards = params.cards
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        if #hand > 0 then
            local posdiscard = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard)
            if epicness and #hand > 5 then
                hand[math.random(#hand)].setPosition(posdiscard)
                local hand2 = o.getHandObjects()
                hand2[math.random(#hand2)].setPosition(posdiscard)
                broadcastToAll("Master Strike: Each player with six or more cards in hand discards two cards at random.")
            elseif not epicness then
                hand[math.random(#hand)].setPosition(posdiscard)
                broadcastToAll("Master Strike: Each player discards a card at random.")
            end
        end
    end
    if cards[1] then
        local bonusval = 1
        if epicness then
            bonusval = bonusval + 1
        end
        strikesstacked = strikesstacked + 1
        cards[1].setTags("Villainous Weapon","Power:+" .. bonusval,"Artifact")
        cards[1].setName("Necrocraft Ship")
        cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
    end
    return nil
end