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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    if twistsresolved == 1 or twistsresolved == 3 or twistsresolved == 5 then
        broadcastToAll("Scheme Twist: Duel of Science! Reveal a silver or blue hero or you will need to discard down to four cards.")
        local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver|Blue")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color, n = #hand - 4})
        end
        if #players >= #Player.getPlayers()/2 then
            cards[1].setName("Duel Won")
            getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
            return nil
        end
    elseif twistsresolved == 2 or twistsresolved == 4 or twistsresolved == 6 then
        broadcastToAll("Scheme Twist: Duel of Magic! Reveal a yellow or red hero or you will need to discard down to four cards.")
        local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Yellow|Red")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color, n = #hand - 4})
        end
        if #players >= #Player.getPlayers()/2 then
            cards[1].setName("Duel Won")
            getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
            return nil
        end
    elseif twistsresolved > 6 and twistsresolved < 12 then
        broadcastToAll("Scheme Twist: Duel of Science and Magic! Reveal at least three of the four colors (excluding green) or you will need to discard down to four cards.")
        local players = Player.getPlayers()
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            local colorsfound = {
                Yellow = 0,
                Silver = 0,
                Blue = 0,
                Red = 0}
            for _,h in pairs(hand) do
                if hasTag2(h,"HC:") and colorsfound[hasTag2(h,"HC:")] then
                    colorsfound[hasTag2(h,"HC:")] = 1
                end
            end
            local colorsfound_n = 0
            for _,c in pairs(colorsfound) do
                colorsfound_n = colorsfound_n + c
            end
            if colorsfound_n > 2 then
                players[o] = nil
            end
        end
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color, n = #hand - 4})
        end
        if #players >= #Player.getPlayers()/2 then
            cards[1].setName("Duel Won")
            getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
            return nil
        end
    end
    return twistsresolved
end