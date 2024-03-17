function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID",
        "woundsDeckGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs",
        "pos_discard"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    local guids3 = {
        "playerBoards"
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

function setupSpecial(params)
    broadcastToAll("Add one hero of your choice to the hero deck! Take three different non-rare cards from that hero and add them to your starting deck.")
    local wndPile = getObjectFromGUID(woundsDeckGUID)
    wndPile.randomize()
    log("Moving wounds to starter decks.")
    for _,o in pairs(Player.getPlayers()) do
        local playerdeck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')[1]
        for j = 1,3 do
            wndPile.takeObject({position=playerdeck.getPosition(),
                flip=false,
                smooth=false})
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    broadcastToAll("twist not scripted")
    return nil
end