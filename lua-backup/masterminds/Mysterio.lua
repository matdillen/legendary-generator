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
        local tacticspile = nil
        local tacticspilecount = 0
        for _,o in pairs(mm) do
            if o.is_face_down == true and o.tag == "Deck" then
                if Global.Call('hasTagD',{deck = o,tag="Tactic:Mysterio"}) then
                    tacticspile = o
                    tacticspilecount = o.getQuantity()
                    break
                end
            elseif o.is_face_down == true then
                if o.hasTag("Tactic:Mysterio") then
                    tacticspile = o
                    tacticspilecount = 1
                    break
                end
            end
        end
        if tacticspile then
            tacticspile.putObject(cards[1])
        else
            for _,o in pairs(mm) do
                Global.Call('bump',{obj = o})
            end
            cards[1].setPositionSmooth(getObjectFromGUID(mmloc).getPosition())
        end
        local mysterioShuffle = function()
            getObjectFromGUID(mmZoneGUID).Call('click_update_tactics',getObjectFromGUID(mmloc))
            local content = Global.Call('get_decks_and_cards_from_zone',mmloc)
            for _,o in pairs(content) do
                if o.is_face_down == true and o.tag == "Deck" and Global.Call('hasTagD',{deck = o,tag="Tactic:Mysterio"}) then
                    o.randomize()
                end
            end
        end
        local newtacticmoved = function()
            local content = Global.Call('get_decks_and_cards_from_zone',mmloc)
            for _,o in pairs(content) do
                if o.is_face_down == true then
                    if o.tag == "Deck" and Global.Call('hasTagD',{deck = o,tag="Tactic:Mysterio"}) and o.getQuantity() == tacticspilecount+1 then
                        return true
                    elseif o.hasTag("Tactic:Mysterio") and o.getQuantity() == tacticspilecount+1 then
                        return true
                    end
                end
            end
            return false
        end
        Wait.condition(mysterioShuffle,newtacticmoved)
    end
    return nil
end