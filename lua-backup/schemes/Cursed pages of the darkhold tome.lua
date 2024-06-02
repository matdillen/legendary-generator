function onLoad()
    darkholdturn = false
    
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids3 = {
        "discardguids"
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

function fightEffect(params)
    if darkholdturn == true then
        local cursedpages = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
        local pos = getObjectFromGUID(discardguids[params.color]).getPosition()
        pos.y = pos.y + 2
        if cursedpages and cursedpages.tag == "Deck" then
            cursedpages.takeObject({position = pos})
            darkholdturn = false
        elseif cursedpages then
            cursedpages.setPosition(pos)
            darkholdturn = false
        end
    end
end

function setupCounter(init)
    if init then
        return {["zoneguid"] = twistZoneGUID,
                ["zoneguid2"] = villainDeckZoneGUID,
                ["tooltip"] = "Cursed pages: __/7.",
                ["tooltip2"] = "Villain deck count: __."}
    else
        local vildeck = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
        if vildeck then
            return math.abs(vildeck.getQuantity())
        else
            return 0
        end
    end
end

function setupCounter2()
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck then
        return math.abs(vildeck.getQuantity())
    else
        return 0
    end
end

function resolveTwist(params)
    local cards = params.cards
    
    darkholdturn = true
    local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
    Wait.condition(
        function()
            darkholdturn = false
        end,
        function()
            if Turns.turn_color == nextcolor then
                return true
            else
                return false
            end
        end)
    cards[1].setName("Cursed Page")
    cards[1].setDescription("RITUAL ARTIFACT: This card remains in play. You may discard it for its effect any time if its condition was fulfilled this turn, even if it wasn't in play at the time.")
    cards[1].setPosition(getObjectFromGUID(twistZoneGUID).getPosition())
    broadcastToAll("Scheme Twist: Put a Cursed Page from play, any discard pile or the KO pile next to the scheme. You may gain one of the pages this turn if you fight a villain or mastermind.")
    return nil
end