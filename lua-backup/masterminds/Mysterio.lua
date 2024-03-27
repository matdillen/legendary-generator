function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local cards = params.cards
    local mmloc = params.mmloc

    if cards[1] then
        cards[1].setName("Mysterio Tactic")
        cards[1].addTag("Tactic:Mysterio")
        cards[1].addTag("VP6")
        cards[1].flip()
        local mm = Global.Call('get_decks_and_cards_from_zone',mmloc)
        if not mm[1] then
            broadcastToAll("Mysterio not found?")
            return nil
        end
        for _,o in pairs(mm) do
            if o.is_face_down == false then
                Global.Call('bump',{obj = o,y = 4})
            end
        end
        cards[1].setPositionSmooth(getObjectFromGUID(mmloc).getPosition())
        local mysterioShuffle = function()
            getObjectFromGUID(mmZoneGUID).Call('click_update_tactics',getObjectFromGUID(mmloc))
            for _,o in pairs(mm) do
                if o.is_face_down == true and o.tag == "Deck" then
                    o.randomize()
                end
            end
        end
        Wait.time(mysterioShuffle,2)
    end
    return nil
end