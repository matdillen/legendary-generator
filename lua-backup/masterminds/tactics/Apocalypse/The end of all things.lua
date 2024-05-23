function onLoad()
    local guids = {
        "playerBoards",
        "kopile_guid"
        }
        
    for _,o in pairs(guids) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
    end
end

function tacticEffect(params)
    local pos = getObjectFromGUID(kopile_guid).getPosition()
    pos.y = pos.y + 2
    for _,o in pairs(Player.getPlayers()) do
        local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
        if deck.tag == "Deck" and deck.getQuantity() > 2 then
            local deckcontent = deck.getObjects()
            for i = 1,3 do
                for _,tag in pairs(deckcontent[i].tags) do
                    if tag:find("Cost:") and tonumber(tag:match("%d+")) > 0 then
                        deck.takeObject({position = pos,
                            smooth = true,
                            index = i})
                        break
                    end
                end
            end
        else
            if not params.terminate then
                getObjectFromGUID(playerBoards[o.color]).Call('click_refillDeck')
                Wait.time(function() tacticEffect({terminate = true}) end,1)
            end
        end
    end
end