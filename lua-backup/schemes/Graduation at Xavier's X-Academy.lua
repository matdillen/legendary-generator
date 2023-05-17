function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local twistpile = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    if twistpile[1] then
        broadcastToAll("Scheme Twist: Bystander moves to escape pile!")
        if twistpile[1].tag == "Deck" then
            twistpile[1].takeObject({position=getObjectFromGUID(escape_zone_guid).getPosition(),
                flip=true,smooth=true})
        else
            twistpile[1].flip()
            twistpile[1].setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
        end
    end
    return twistsresolved
end
