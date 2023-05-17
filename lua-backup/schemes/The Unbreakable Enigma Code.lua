function onLoad()   
    local guids1 = {
        "heroDeckZoneGUID",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    if twistsresolved < 6 then
        local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)
        if herodeck[1] and herodeck[1].tag == "Deck" then
            herodeck[1].takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                smooth = true})
        elseif herodeck[1] then
            herodeck[1].setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
        else
            broadcastToAll("Hero deck ran out!")
            return twistsresolved
        end
        local shufflethecode = function()
            local code = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
            code[1].randomize()
            broadcastToAll("Scheme Twist: Card from the hero deck added to the Enigma Code!")
        end
        Wait.time(shufflethecode,2)
    elseif twistsresolved == 6 then
        broadcastToAll("Scheme Twist: Evil Wins!")
    end
    return twistsresolved
end
