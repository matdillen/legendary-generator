function onLoad()
    local guids1 = {
        "heroDeckZoneGUID",
        "twistZoneGUID",
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function updatePower()
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    log(cards)
    function ultronCallback(obj)
        Wait.time(updatePower,1)
    end
    local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)
    if herodeck[1] then
        if herodeck[1].tag == "Deck" then
            herodeck[1].takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                flip=true,
                callback_function = ultronCallback})
        else
            herodeck[1].flip()
            herodeck[1].setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
            Wait.time(updatePower,1)
        end
    end
    cards[1].setName("Evolved Ultron")
    cards[1].setTags({"VP6","Villain","Power:4"})
    cards[1].setDescription("EMPOWERED: This card gets extra Power for each Hero with the listed Hero Class in the Evolution Pile.")
    return twistsresolved
end