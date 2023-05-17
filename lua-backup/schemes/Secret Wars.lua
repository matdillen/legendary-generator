function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmPileGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 4 then
        local mmPile = getObjectFromGUID(mmPileGUID)
        mmPile.randomize()
        local stripTactics = function(obj)
            obj.flip()
            local mmZone = getObjectFromGUID(mmZoneGUID)
            mmZone.Call('updateMasterminds',obj.getName())
            mmZone.Call('updateMastermindsLocation',{obj.getName(),topBoardGUIDs[4+2*(twistsresolved-1)]})
            mmZone.Call('setupMasterminds',{obj = obj,epicness = false,tactics = 1})
            local keep = math.random(4)
            local tacguids = {}
            for i = 1,4 do
                table.insert(tacguids,obj.getObjects()[i].guid)
            end
            local tacticsPile = getObjectFromGUID(topBoardGUIDs[2])
            for i = 1,4 do
                if i ~= keep then
                    obj.takeObject({position = tacticsPile.getPosition(),
                        guid = tacguids[i],
                        flip = true})
                end
            end
            local flipTactics = function()
                if obj then
                    local pos = obj.getPosition()
                    pos.y = pos.y + 3
                    obj.takeObject({position = pos,
                        index = obj.getQuantity()-1,
                        flip=true})
                end
            end
            Wait.time(flipTactics,1)
        end
        mmPile.takeObject({position = getObjectFromGUID(topBoardGUIDs[4+2*(twistsresolved-1)]).getPosition(),
            callback_function = stripTactics})
    elseif twistsresolved == 8 then
        broadcastToAll("Scheme Twist: Evil Wins!")
    end
    return twistsresolved
end
