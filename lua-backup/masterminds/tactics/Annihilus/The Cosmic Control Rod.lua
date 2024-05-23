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
        if o.color ~= Turns.turn_color then
            local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
            if deck.tag == "Deck" and deck.getQuantity() > 2 then
                local deckcontent = deck.getObjects()
                local cost = -1
                local guids = {}
                for i = 1,3 do
                    for _,tag in pairs(deckcontent[i].tags) do
                        if tag:find("Cost:") and tonumber(tag:match("%d+")) > cost then
                            cost = tonumber(tag:match("%d+"))
                            guids = {deckcontent[i].guid}
                        elseif tag:find("Cost:") and tonumber(tag:match("%d+")) == cost then
                            table.insert(guids,deckcontent[i].guid)
                        end
                    end
                    if cost == -1 then
                        cost = 0
                        table.insert(guids,deckcontent[i].guid)
                    end
                end
                if guids[2] then
                    getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = Turns.turn_color,
                        pile = deck,
                        guids = guids,
                        targetpos = pos,
                        flip = true,
                        label = "KO",
                        toolt = "KO this hero."})
                else
                    deck.takeObject({position = pos, smooth = false,guid = guids[1]})
                end
            else
                if not params.terminate then
                    getObjectFromGUID(playerBoards[o.color]).Call('click_refillDeck')
                    Wait.time(function() tacticEffect({terminate = true}) end,1)
                end
            end
        end
    end
end