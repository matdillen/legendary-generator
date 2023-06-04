function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmPileGUID",
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    if twistsresolved == 1 then
        local mmPile = getObjectFromGUID(mmPileGUID)
        mmPile.randomize()
        local stripTactics = function(obj)
            obj.flip()
            local mmZone = getObjectFromGUID(mmZoneGUID)
            mmZone.Call('updateMasterminds',obj.getName())
            mmZone.Call('updateMastermindsLocation',{obj.getName(),topBoardGUIDs[4]})
            mmZone.Call('setupMasterminds',{obj = obj, epicness = false,tactics = 1})
            local keep = math.random(4)
            local tacguids = {}
            for i = 1,4 do
                table.insert(tacguids,obj.getObjects()[i].guid)
            end
            local tacticsPile = getObjectFromGUID(topBoardGUIDs[2])
            for i = 1,4 do
                if i ~= keep and obj then
                    obj.takeObject({position = tacticsPile.getPosition(),
                        guid = tacguids[i],
                        flip = true})
                end
            end
            if obj then
                local flipTactics = function()
                    local pos = obj.getPosition()
                    pos.y = pos.y + 3
                    obj.takeObject({position = pos,
                        index = obj.getQuantity()-1,
                        flip=true})
                end
                Wait.time(flipTactics,1)
            end
        end
        mmPile.takeObject({position = getObjectFromGUID(topBoardGUIDs[4]).getPosition(),callback_function = stripTactics})
    elseif twistsresolved < 5 then
        local allianceMM = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[4])
        local mmcard = nil
        if allianceMM[1] then
            for _,o in pairs(allianceMM) do
                if o.hasTag("Tactic:Hydra High Council") or o.hasTag("Tactic:Hydra Super Adaptoid") then
                    local tacticsPile = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[2])
                    local tacticShuffle = function(obj)
                        Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[4])[1].randomize()
                    end
                    if tacticsPile[1].getQuantity() > 1 then
                        tacticsPile[1].takeObject({position = allianceMM[1].getPosition(),
                            flip=true,
                            smooth=false,
                            callback_function = tacticShuffle})
                    else
                        local ann = tacticsPile[1].setPosition(allianceMM[1].getPosition())
                        tacticShuffle(ann)
                    end
                    return twistsresolved
                end
                for _,k in pairs(table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))) do
                    if k:find(o.getName(),1,true) and o.tag == "Card" then
                        mmcard = o
                        break
                    end
                end
                if mmcard then
                    break
                end
            end
            if not mmcard then
                broadcastToAll("Alliance mastermind card not found.")
                return nil
            end
            local tacticShuffle = function(obj)
                Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[4])[1].randomize()
            end
            local addTactic = function()
                local tacticsPile = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[2])
                if tacticsPile[1].getQuantity() > 1 then
                    tacticsPile[1].takeObject({position = allianceMM[1].getPosition(),
                        flip=false,
                        smooth=false,
                        callback_function = tacticShuffle})
                else
                    local ann = tacticsPile[1].setPosition(allianceMM[1].getPosition())
                    tacticShuffle(ann)
                end
            end
            Global.Call('bump',{obj = mmcard, y = 6})
            addTactic()
            Wait.time(function() 
                getObjectFromGUID(mmZoneGUID).Call('click_update_tactics',getObjectFromGUID(topBoardGUIDs[4]))
                end,1.5)
        end
    elseif twistsresolved < 7 then
        local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
        for _,o in pairs(table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))) do
            getObjectFromGUID(pushvillainsguid).Call('addBystanders',mmLocations[o])
        end
    elseif twistsresolved == 7 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end