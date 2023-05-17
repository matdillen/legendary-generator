function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playguids"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    if twistsresolved < 8 then
        local worthy = 0
        local iter = 0
        local players = Player.getPlayers()
        for i,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            if hand[1] then
                for _,obj in pairs(hand) do
                    if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 4 then
                        worthy = worthy + 1
                        table.remove(players,i-iter)
                        iter = iter + 1
                        break
                    end
                end
            end
            if players[i] and players[i].color == o.color then
                local play = Global.Call('get_decks_and_cards_from_zone',playguids[o.color])
                if play[1] then
                    for _,obj in pairs(play) do
                        if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 4 then
                            worthy = worthy + 1
                            table.remove(players,i-iter)
                            iter = iter + 1
                            break
                        end
                    end
                end
            end
        end
        for _,o in pairs(players) do
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',o.color)
            broadcastToColor("Scheme Twist: You are not Worthy, so discard a card.",o.color,o.color)
        end
        if worthy/#Player.getPlayers() <= 0.5 then
            getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
            broadcastToAll("Scheme Twist: Moral Failing! Not enough players were worthy.")
        else
            getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
            broadcastToAll("Scheme Twist: Enough players were worthy.")
        end
    elseif twistsresolved < 12 then
        getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
        broadcastToAll("Scheme Twist: Moral Failing!")
    end
    return nil
end