function onLoad()
    delay = 0
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function dormammuDiscard(params)
    local hand = Player[params.color].getHandobjects()
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = params.color,
        n = #hand - 4 + delay})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    delay = 0
    if epicness then
        for _,p in pairs(Player.getPlayers()) do
            local playerBoard = getObjectFromGUID(playerBoards[p.color])
            local posdiscard = playerBoard.positionToWorld(pos_discard)
            local deck = playerBoard.Call('returnDeck')[1]
            local performDemonicBargain = function()
                if not deck then
                    deck = playerBoard.Call('returnDeck')[1]
                end
                if deck and deck.tag == "Deck" then
                    for _,tag in pairs(deck.getObjects()[1].tags) do
                        if not tag:find("Cost:") or (tag:find("Cost:") and tonumber(tag:match("%d+")) == 0) then
                            deck.takeObject({position = posdiscard,
                                flip = true,
                                smooth = true})
                            break
                        end
                    end
                elseif deck then
                    if not hasTag2(deck,"Cost:") or hasTag2(deck,"Cost:") == 0 then
                        deck.setPosition(posdiscard)
                    end
                end
            end
            if deck then
                performDemonicBargain()
            else
                playerBoard.Call('click_refillDeck')
                deck = nil
                Wait.time(performDemonicBargain,2)
            end
        end
        delay = 1
    end
    for _,p in pairs(Player.getPlayers()) do
        local hand = p.getHandObjects()
        Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('demonicBargain',{color = p.color,
            triggerf = 'dormammuDiscard',
            args = "self",
            fsourceguid = self.guid}) end,delay)
    end
    return strikesresolved        
end
