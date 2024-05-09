function onLoad()
    local guids3 = {
        "discardguids",
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

function tacticEffect(params)
    for _,o in pairs(Player.getPlayers()) do
        local posdiscard = getObjectFromGUID(discardguids[o.color]).getPosition()
        local playerBoard = getObjectFromGUID(playerBoards[o.color])
        local deck = playerBoard.Call('returnDeck')[1]
        local hoodDiscards = function()
            if not deck then
                deck = playerBoard.Call('returnDeck')[1]
            end
            local deckcards = deck.getObjects()
            local todiscard = {}
            for i=1,6 do
                for _,k in pairs(deckcards[i].tags) do
                    if k:find("HC:") or k == "Split" then
                        table.insert(todiscard,deckcards[i].guid)
                        break
                    end
                end
            end
            if todiscard[1] then
                for i=1,#todiscard do
                    deck.takeObject({position = posdiscard,
                        flip = true,
                        smooth = true,
                        guid = todiscard[i]})
                    if deck.remainder and i < #todiscard then
                        deck.remainder.flip()
                        deck.remainder.setPositionSmooth(posdiscard)
                    end
                end
            end
        end
        if deck and deck.getQuantity() > 5 then
            hoodDiscards()
        else
            playerBoard.Call('click_refillDeck')
            deck = nil
            Wait.time(hoodDiscards,2)
        end
   end
   broadcastToAll("Maximus Fight effect: Maximus deploys the Sieve of Secrets. Each player discards all non-grey heroes from the top 6 cards of their deck.")
end