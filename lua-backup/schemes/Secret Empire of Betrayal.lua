function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "mmZoneGUID",
        "setupGUID",
        "heroPileGUID"
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

function betrayalDeck(obj)
    obj.randomize()
    obj.flip()
    local keepguids= {}
    local objcontent = obj.getObjects()
    for _,o in pairs(objcontent) do
        for _,k in pairs(o.tags) do
            if k:find("Cost:") and tonumber(k:match("%d+")) < 6 then
                table.insert(keepguids,o.guid)
                break
            end
        end
        if #keepguids == 5 then
            break
        end
    end
    local falsepos = getObjectFromGUID(heroPileGUID).getPosition()
    falsepos.x = falsepos.x + 15
    for i=1,14 do
        local tonext = false
        for j=1,5 do
            if keepguids[j] and objcontent[i].guid == keepguids[j] then
               tonext = true 
               --duplicate guids can occur, so remove found ones from table
               table.remove(keepguids,j)
               break
            end
        end
        if tonext == false then
            obj.takeObject({position=falsepos,
                guid = objcontent[i].guid,
                smooth=false})
        end
    end
end

function setupSpecial(params)
    log("Extra hero in dark betrayal pile.")
    getObjectFromGUID(mmZoneGUID).Call('lockTopZone',topBoardGUIDs[5])
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = params.setupParts[9],
        pileGUID = heroPileGUID,
        destGUID = topBoardGUIDs[5],
        callbackf = "betrayalDeck",
        fsourceguid = self.guid})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    cards[1].flip()
    cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[5]).getPosition())
    local twistAdded = function()
        local darkloyalty = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[5])
        if darkloyalty[1] and darkloyalty[1].getQuantity() == 6 then
            return true
        else
            return false
        end
    end
    local twistPlay = function()
        local darkloyalty = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[5])
        darkloyalty[1].randomize()
        local darkCard = darkloyalty[1].getObjects()[1]
        if darkCard.name == "Scheme Twist" then
            darkloyalty[1].takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                flip=true})
            for _,o in pairs(Player.getPlayers()) do
                if o.color ~= Turns.turn_color then
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                    broadcastToAll("Scheme Twist: Vicious Betrayal!")
                end
            end
        else
            local dest = getObjectFromGUID(discardguids[Turns.turn_color]).getPosition()
            dest.y = dest.y + 3
            darkloyalty[1].takeObject({position = dest,
                flip=true})
            broadcastToAll("Scheme Twist: " .. Turns.turn_color .. " player gained a random hero!")
        end
    end
    Wait.condition(twistPlay,twistAdded)
    return nil
end