function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

end

function resolveTwist(params)
    local cards = params.cards
    
    cards[1].setName("Cursed Page")
    cards[1].setDescription("RITUAL ARTIFACT: This card remains in play. You may discard it for its effect any time if its condition was fulfilled this turn, even if it wasn't in play at the time.")
    cards[1].setPosition(getObjectFromGUID(twistZoneGUID).getPosition())
    broadcastToAll("Scheme Twist: Put a Cursed Page from play, any discard pile or the KO pile next to the scheme. You may gain one of the pages this turn if you fight a villain or mastermind."
    return nil
end