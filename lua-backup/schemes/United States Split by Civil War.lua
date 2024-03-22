function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS",
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function setupSpecial(params)
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 1,2 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    for i=4,5 do
        local cardz = Global.Call('get_decks_and_cards_from_zone',city[i])
        if cardz[1] then
            for _,o in pairs(cardz) do
                if o.hasTag("Villain") then
                    cards[1].setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[10]).getPosition())
                    cards[1].setName("Western State Victory")
                    broadcastToAll("Scheme Twist! Western State Victory!")
                    return nil
                end
            end
        end
    end
    local cardz = Global.Call('get_decks_and_cards_from_zone',city[1])
    if cardz[1] then
        for _,o in pairs(cardz) do
            if o.hasTag("Villain") then
                cards[1].setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[11]).getPosition())
                cards[1].setName("Eastern State Victory")
                broadcastToAll("Scheme Twist! Eastern State Victory!")
                return nil
            end
        end
    end
    return twistsresolved
end