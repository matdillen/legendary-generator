function onLoad()
    strikesstacked = 0
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
    local cards = params.cards
    local strikeloc = params.strikeloc

    if cards[1] then
        strikesstacked = strikesstacked + 1
        cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
    end
    local todiscard=  getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait="X-Force",prefix="Team:"})
    if todiscard[1] then
            for _,o in pairs(todiscard) do
                local hand = o.getHandObjects()
                if hand[1] then
                    local posdiscard = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard)
                    hand[math.random(#hand)].setPosition(posdiscard)
                    broadcastToAll("Master Strike: Player " .. o.color .. " had no X-Force heroes and discarded a card at random.")
                end
            end
        end
    return nil
end
