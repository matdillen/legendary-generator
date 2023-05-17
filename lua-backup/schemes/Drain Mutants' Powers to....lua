function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "sidekickZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    local kidnappedmutants = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    local sidekickdeck = Global.Call('get_decks_and_cards_from_zone',sidekickZoneGUID)[1]
    if twistsresolved < 7 then
        for i = 1,2 do
            sidekickdeck.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                flip = false,
                smooth = true})
        end
        if kidnappedmutants[1] then
            Global.Call('bump',{obj = sidekickdeck})
            kidnappedmutants[1].setPositionSmooth(getObjectFromGUID(sidekickZoneGUID).getPosition())
            cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
            return nil
        end
    elseif twistsresolved == 7 then
        if kidnappedmutants[1] then
            Global.Call('bump',{obj = sidekickdeck})
            kidnappedmutants[1].setPositionSmooth(getObjectFromGUID(sidekickZoneGUID).getPosition())
        end
        getObjectFromGUID(pushvillainsguid).Call('unveilScheme')
        return nil
    end
    return twistsresolved
end