function onLoad()
    local guids1 = {
        "pushvillainsguid",
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

    broadcastToAll("Master Strike: Carnage feasts on each player!")
    for _,o in pairs(Player.getPlayers()) do
        local carnageWounds = function(obj)
            local name = obj.getName()
            if name == "" then
                name = "an unnamed card"
            end
            broadcastToColor("Carnage feasted on " .. name .. "!",o.color,o.color)
            if not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") == 0 then
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
            end
        end
        local feastOn = function()
            local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
            if deck[1] and deck[1].tag == "Deck" then
                local pos = getObjectFromGUID(kopile_guid).getPosition()
                deck[1].takeObject({position = pos,
                    flip=true,
                    smooth = true,
                    callback_function = carnageWounds})
                return true
            elseif deck[1] then
                deck[1].flip()
                getObjectFromGUID(pushvillainsguid).Call('koCard',deck[1]) --was smooth before
                carnageWounds(deck[1])
                return true
            else
                return false
            end
        end
        local feasted = feastOn()
        if feasted == false then
            local discarded = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
            if discarded[1] then
                getObjectFromGUID(playerBoards[o.color]).Call('click_refillDeck')
                local playerdeckpresent = function()
                    local playerdeck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
                    if playerdeck[1] then
                        return true
                    else
                        return false
                    end
                end
                Wait.condition(feastOn,playerdeckpresent)
            end
        end
    end
    return strikesresolved
end
