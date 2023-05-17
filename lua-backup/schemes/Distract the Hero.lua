function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    broadcastToAll("Scheme Twist: If you get any Victory Points this turn, put this Twist on the bottom of the Villain Deck. Otherwise, stack this Twist next to the Scheme as a Villainous Interruption.")
    local pcolor = Turns.turn_color
    local guid = cards[1].guid
    local turnChanged = function()
        if Turns.turn_color == pcolor then
            return false
        else
            return true
        end
    end
    local villainousInterruption = function()
        local card = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
        if card[1] and card[1].guid == guid then
            getObjectFromGUID(pushvillainsguid).Call('stackTwist',card[1])
            broadcastToAll("Last turn's twist stacked next to the Scheme as a Villainous Interruption.")
        end
    end
    Wait.condition(villainousInterruption,turnChanged)
    return nil
end