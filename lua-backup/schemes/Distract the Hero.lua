function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "twistZoneGUID"
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

function setupCounter(init)
    if init then
        return {["zoneguid"] = twistZoneGUID,
                ["tooltip"] = "Villainous interruptions: __/5."}
    else
        local vildeck = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
        if vildeck then
            return math.abs(vildeck.getQuantity())
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    broadcastToAll("Scheme Twist: If you get any Victory Points this turn, this Twist will go to the bottom of the Villain Deck. Otherwise, this Twist will be stacked next to the Scheme as a Villainous Interruption.")
    local pcolor = Turns.turn_color
    local guid = cards[1].guid
    local vpilescore = getObjectFromGUID(playerBoards[Turns.turn_color]).Call('calculate_vp_call',{warn = true}) or 0
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
    local noDistraction = function()
        local villaindeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
        Global.Call('bump',{obj = villaindeck,y=4})
        cards[1].flip()
        villaindeck.putObject(cards[1])
    end
    local vpGained = function()
        local vpilescore_check = getObjectFromGUID(playerBoards[Turns.turn_color]).Call('calculate_vp_call',{warn = true}) or 0
        if vpilescore_check > vpilescore then
            return true
        elseif vpilescore_check < vpilescore then
            vpilescore = vpilescore_check
            return false
        else
            return false
        end
    end
    Wait.condition(noDistraction,vpGained)
    Wait.condition(villainousInterruption,turnChanged)
    return nil
end