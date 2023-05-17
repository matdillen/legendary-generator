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
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
end

function table.clone(val)
    local new = {}
    for i,o in pairs(val) do
        new[i] = o
    end
    return new
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    local pcolor = Turns.turn_color
    if pcolor == "White" then
        angle = 90
    elseif pcolor == "Blue" then
        angle = -90
    else
        angle = 180
    end
    local brot = {x=0, y=angle, z=0}
    local playerBoard = getObjectFromGUID(playerBoards[pcolor])
    local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
    dest.y = dest.y + 3
    broadcastToAll("Scheme Twist: Angry Mob moved to " .. pcolor .. " player's discard pile!")
    cards[1].setName("Angry Mob")
    cards[1].addTag("Angry Mob")
    cards[1].setRotationSmooth(brot)
    cards[1].setPositionSmooth(dest)
    return nil
end

function onPlayerTurn(player,previous_player)
    local hand = player.getHandObjects()
    if hand[1] then
        for _,o in pairs(hand) do
            if o.getName() == "Angry Mob" and o.hasTag("Angry Mob") then
                broadcastToAll("Angry Mob! " .. previous_player.color .. " player was assaulted by an angry mob from " .. player.color .. " and wounded.")
                local playerBoard = getObjectFromGUID(playerBoards[previous_player.color])
                local dest = playerBoard.positionToWorld(pos_discard)
                dest.y = dest.y + 3
                if previous_player.color == "White" then
                    angle = 90
                elseif previous_player.color == "Blue" then
                    angle = -90
                else
                    angle = 180
                end
                local brot = {x=0, y=angle, z=0}
                o.use_hands = false
                o.setRotationSmooth(brot)
                o.setPositionSmooth(dest)
                Wait.time(function() o.use_hands = true end,1)
                getObjectFromGUID(pushvillainsguid).Call('getWound',previous_player.color)
            end
        end
    end
end