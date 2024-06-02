function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "woundszoneguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "discardguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
end

function table.clone(val)
    local new = {}
    for i,o in pairs(val) do
        new[i] = o
    end
    return new
end

function setupCounter(init)
    if init then
        return {["zoneguid"] = woundszoneguid,
                ["tooltip"] = "Wound stack count: __.",
                ["tooltip2"] = "Villain deck count: __."}
    else
        local woundsdeck = Global.Call('get_decks_and_cards_from_zone',woundszoneguid)[1]
        if woundsdeck then
            return math.abs(woundsdeck.getQuantity())
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
    local twistsresolved = params.twistsresolved
    local cards = params.cards

    local dest = getObjectFromGUID(discardguids[Turns.turn_color]).getPosition()
    dest.y = dest.y + 3
    broadcastToAll("Scheme Twist: Angry Mob moved to " .. Turns.turn_color .. " player's discard pile!")
    cards[1].setName("Angry Mob")
    cards[1].addTag("Angry Mob")
    cards[1].setPositionSmooth(dest)
    return nil
end

function onPlayerTurn(player,previous_player)
    local hand = player.getHandObjects()
    if hand[1] then
        for _,o in pairs(hand) do
            if o.getName() == "Angry Mob" and o.hasTag("Angry Mob") then
                broadcastToAll("Angry Mob! " .. previous_player.color .. " player was assaulted by an angry mob from " .. player.color .. " and wounded.")
                local dest = getObjectFromGUID(discardguids[previous_player.color]).getPosition()
                dest.y = dest.y + 3
                o.use_hands = false
                o.setPositionSmooth(dest)
                Wait.time(function() o.use_hands = true end,1)
                getObjectFromGUID(pushvillainsguid).Call('getWound',previous_player.color)
            end
        end
    end
end