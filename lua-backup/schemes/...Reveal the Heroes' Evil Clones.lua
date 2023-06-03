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
    
    local guids3 = {
        "resourceguids",
        "attackguids",
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

function revealScheme()
    local manipulations = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])[1]
    if manipulations then
        manipulations_stacked = math.abs(manipulations.getQuantity())
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    
    manipulations_stacked = manipulations_stacked + 1
    cards[1].setPosition(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
    --top card of hero deck becomes villain
    --and gets cloned from hq or hero deck
    --requires identifying individual hero cards
    broadcastToAll("Twist effect not scripted!")
    return nil
end