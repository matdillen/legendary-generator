function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
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

    local guids3 = {
        "resourceguids"
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

function moveToxin(obj,player_clicker_color)
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    if recruit < 2 then
        broadcastToColor("You don't have enough recruit to deal with this toxin!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-2)
    obj.flip()
    obj.setPositionSmooth(getObjectFromGUID(villainDeckZoneGUID).getPosition())
    local shuffleToxin = function()
        Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1].randomize()
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    end
    Wait.time(shuffleToxin,1.5)
end

function resolveTwist(params)
    local cards = params.cards

    broadcastToAll("Scheme Twist: Trap! By End of Turn: You may pay 2*. If you do, shuffle this Twist back into the Villain Deck, then play a card from the Villain Deck.") 
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
        label = "2*",
        color = "Yellow",
        tooltip = "Pay two Recruit by end of turn to shuffle this toxin back.",
        click_f = "moveToxin"})
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
            cards[1].clearButtons()
            getObjectFromGUID(pushvillainsguid).Call('stackTwist',card[1])
            broadcastToAll("Last turn's twist stacked next to the Scheme as an Airborne Neurotoxin.")
        end
    end
    Wait.condition(villainousInterruption,turnChanged)
    return nil
end