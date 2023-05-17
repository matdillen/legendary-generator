function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local mmloc = params.mmloc

    local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmloc))
    if transformedPV == true then
        getObjectFromGUID(pushvillainsguid).Call('crossDimensionalRampage',"void")
    elseif transformedPV == false then
        local playercolors = Player.getPlayers()
        broadcastToAll("Master Strike: The Void feasts on each player!")
        for i=1,#playercolors do
            local color = playercolors[i].color
            local carnageWounds = function(obj)
                local name = obj.getName()
                if name == "" then
                    name = "an unnamed card"
                end
                broadcastToColor("The Void feasted on " .. name .. "!",color,color)
                if not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") == 0 then
                    getObjectFromGUID(pushvillainsguid).Call('getWound',color)
                end
            end
            local feastOn = function()
                local deck = getObjectFromGUID(playerBoards[color]).Call('returnDeck')
                if deck[1] and deck[1].tag == "Deck" then
                local pos = getObjectFromGUID(kopile_guid).getPosition()
                -- adjust pos to ensure the callback is triggered
                pos.y = pos.y + i
                    deck[1].takeObject({position = pos,
                        flip=true,
                        callback_function = carnageWounds})
                    return true
                elseif deck[1] then
                    deck[1].flip()
                    getObjectFromGUID(pushvillainsguid).Call('koCard',deck[1])
                    carnageWounds(deck[1])
                    return true
                else
                    return false
                end
            end
            local feasted = feastOn()
            if feasted == false then
                local discard = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
                if discard[1] then
                    getObjectFromGUID(playerBoards[color]).Call('click_refillDeck')
                    Wait.time(feastOn,2)
                end
            end
        end
    end
    return strikesresolved
end
