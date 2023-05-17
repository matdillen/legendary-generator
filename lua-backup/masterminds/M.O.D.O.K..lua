function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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
        for _,o in pairs(Player.getPlayers()) do
            if not getObjectFromGUID(pushvillainsguid).Call('outwitPlayer',{color = o.color, n = 4}) then
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
            end
        end
    elseif transformedPV == false then
        for _,o in pairs(Player.getPlayers()) do
            if not outwitPlayer({color = o.color, n = 3}) then
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
                    if discardguids[1] then
                        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                            pile = discarded[1],
                            guids = discardguids,
                            resolve_function = 'koCard',
                            tooltip = "KO this hero.",
                            label = "KO"})
                        broadcastToColor("Master Strike: You failed to outwit M.O.D.O.K., so KO a non-grey hero from your discard pile.",o.color,o.color)
                    end
                elseif discarded[1] then
                    if hasTag2(discarded[1],"HC:",4) then
                        getObjectFromGUID(pushvillainsguid).Call('koCard',discarded[1])
                        broadcastToColor("Master Strike: You failed to outwit M.O.D.O.K., so the only non-grey hero from your discard pile was KO'd.",o.color,o.color)
                    end
                end
            end
        end
    end
    return strikesresolved
end
