function onLoad()
    local guids1 = {
        "pushvillainsguid"
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

function threatAnalysis(params)
    params.obj.setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness
    strikeloc = params.strikeloc

    for _,o in pairs(Player.getPlayers()) do
        if epicness then
            local hand = o.getHandObjects()
            local handi = table.clone(hand)
            local iter = 0
            if hand[1] then
                for i,h in pairs(handi) do
                    if not hasTag2(h,"HC:",4) then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                end
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = hand,
                    pos = getObjectFromGUID(strikeloc).getPosition()})
                broadcastToColor("Master Strike: Put a non-grey Hero from your hand into a Threat Analysis pile next to Ultron.",o.color,o.color)
            end
        else
            local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver")
            broadcastToColor("Master Strike: Put a non-grey Hero from your discard pile into a Threat Analysis pile next to Ultron.",o.color,o.color)
            for _,o in pairs(players) do
                local discardguids = {}
                local discarded = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
                if discarded[1] and discarded[1].tag == "Deck" then
                    for _,c in pairs(discarded[1].getObjects()) do
                        for _,tag in pairs(c.tags) do
                            if tag:find("HC:") or tag == "Split" then
                                table.insert(discardguids,c.guid)
                                break
                            end
                        end
                    end
                    if discardguids[1] and discardguids[2] then
                        offerCards({color = o.color,
                            pile = discarded[1],
                            guids = discardguids,
                            resolve_function = 'threatAnalysis',
                            args = "self",
                            fsourceguid = self.guid,
                            tooltip = "Put this hero from your discard pile into Ultron's Threat Analysis pile.",
                            label = "TA"})
                        broadcastToColor("Master Strike: Ultron seizes a non-grey hero from your discard pile for Threat Analysis.",o.color,o.color)
                    elseif discardguids[1] then
                        discarded[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                            guid = discardguids[1],
                            smooth = true})
                        broadcastToColor("Master Strike: Ultron seizes the only non-grey hero from your discard pile for Threat Analysis.",o.color,o.color)
                    end
                elseif discarded[1] then
                    if hasTag2(discarded[1],"HC:") then
                        discarded[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
                        broadcastToColor("Master Strike: Ultron seizes the only non-grey hero from your discard pile for Threat Analysis.",o.color,o.color)
                    end
                end
            end
        end
    end
    return strikesresolved
end
