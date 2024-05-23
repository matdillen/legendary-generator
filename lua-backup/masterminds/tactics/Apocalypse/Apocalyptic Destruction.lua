function onLoad()
    local guids = {
        "playerBoards",
        "kopile_guid",
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
    end
end

function tacticEffect(params)
    for _,p in pairs(Player.getPlayers()) do
        local discard = getObjectFromGUID(playerBoards[p.color]).Call('returnDiscardPile')
        if discard.tag == "Deck" then
            local toko = {}
            for _,o in pairs(discard.getObjects()) do
                for _,tag in pairs(o.tags) do
                    if tag:find("Cost:") and tonumber(tag:match("%d+")) > 0 then
                        table.insert(toko,o.guid)
                        break
                    end
                end
            end
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{
                color = Turns.turn_color,
                pile = discard,
                guids = toko,
                resolve_function = "koCard",
                fsourceguid = pushvillainsguid,
                label = "KO",
                toolt = "KO this card.",
                n = 2,
                args = "self"
            })
        else
            if Global.Call('hasTag2',{obj = discard,tag = "Cost:"}) and Global.Call('hasTag2',{obj = discard,tag = "Cost:"}) > 0 then
                getObjectFromGUID(pushvillainsguid).Call('koCard',discard)
            end
        end
    end
end