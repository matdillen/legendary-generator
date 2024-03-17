function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "heroPileGUID",
        "mmZoneGUID"
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

function setupSpecial(params)
    log("Set up Adam Warlock pile.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = "Adam Warlock (ITC)",
        pileGUID = heroPileGUID,
        destGUID = topBoardGUIDs[1],
        callbackf = "orderAdam",
        fsourceguid = self.guid})
    getObjectFromGUID(mmZoneGUID).Call('lockTopZone',topBoardGUIDs[1])
end

function orderAdam(obj)
    for _,o in pairs(obj.getObjects()) do
        local pos = obj.getPosition()
        for _,k in pairs(o.tags) do
            if k:find("Cost:") then
                pos.y = pos.y + 12 - k:match("%d+")
                break
            end
        end
        if obj.getQuantity() > 1 then
            obj.takeObject({position=pos,
                guid = o.guid})
            if obj.remainder then
                obj = obj.remainder
            end
        else
            obj.setPositionSmooth(pos)
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local adam = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])
    local setUnPure = function(obj)
        obj.addTag("Unpure")
    end
    if adam[1] then
        adam[1].takeObject({position = getObjectFromGUID(pushvillainsguid).getPosition(),
            callback_function = setUnPure})
        broadcastToAll("Scheme Twist: Purify Adam or his soul becomes more corrupted!")
    else
        broadcastToAll("Adam not found?")
    end
    return twistsresolved
end
