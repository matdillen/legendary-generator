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
    local epicness = params.epicness

    if epicness then
        for _,o in pairs(Player.getPlayers()) do
            local playerBoard = getObjectFromGUID(playerBoards[o.color])
            local deck = playerBoard.Call('returnDeck')[1]
            local posdiscard = playerBoard.positionToWorld(pos_discard)
            local posdraw = playerBoard.positionToWorld({0.957, 0.178, 0.222})
            if deck then
                deck.flip()
                deck.setPosition(posdiscard)
            end
            local hoodResets = function()
                local discard = playerBoard.Call('returnDiscardPile')[1]
                local greyguids = {}
                for _,obj in pairs(discard.getObjects()) do
                    local colored = false
                    for _,k in pairs(obj.tags) do
                        if k:find("HC:") or k == "Split" then
                            colored = true
                            break
                        end
                    end
                    if not colored then
                        table.insert(greyguids,obj.guid)
                    end
                end
                while #greyguids > 6 do
                    table.remove(greyguids,math.random(#greyguids))
                end
                for _,k in pairs(greyguids) do
                    discard.takeObject({position = posdraw,
                        flip = true,
                        smooth = true})
                end
            end
            Wait.time(hoodResets,1)
        end
    else
       for _,o in pairs(Player.getPlayers()) do
            local playerBoard = getObjectFromGUID(playerBoards[o.color])
            local posdiscard = playerBoard.positionToWorld(pos_discard)
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
    end
    return strikesresolved
end
