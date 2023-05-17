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
    local city = params.city

    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if hasTag2(obj,"Cost:") then
                    getObjectFromGUID(pushvillainsguid).Call('koCard',obj)
                end
            end
        end
    end
    broadcastToAll("Scheme Twist: all Heroes captured by enemies KO'd. Play another card from the Villain Deck.") 
    getObjectFromGUID(pushvillainsguid).Call('playVillains')
    return nil
end