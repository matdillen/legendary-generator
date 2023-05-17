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
        "vpileguids"
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
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
                local vpilewarbound = {}
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,k in pairs(vpilecontent[1].getObjects()) do
                        for _,tag in pairs(k.tags) do
                            if tag == "Group:Warbound" then 
                                table.insert(vpilewarbound,k.guid)
                                break
                            end
                        end
                    end
                    if vpilewarbound[1] and not vpilewarbound[2] then
                        vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                            smooth = true,
                            guid = vpilewarbound[1]})
                    elseif vpilewarbound[1] and vpilewarbound[2] then
                        offerCards({color = i,
                            pile = vpilecontent[1],
                            guids = vpilewarbound,
                            resolve_function = 'koCard',
                            tooltip = "KO this villain.",
                            label = "KO"})
                        broadcastToColor("KO 1 of the " .. #vpilewarbound .. " villain cards that were put into play from your victory pile.",i,i)
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                    end
                elseif vpilecontent[1] then
                    if vpilecontent[1].hasTag("Group:Warbound") then
                        vpilecontent[1].setPosition(getObjectFromGUID(kopile_guid).getPosition())
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                    end
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                end
            end
        end
    elseif transformedPV == false then
        broadcastToAll("Master Strike: Each player reveals their hand, then KO's a card from their hand or discard pile that has the same card name as a card in the HQ. (not scripted!)")
        --could be scripted, but tricky with both hand and discard pile zones
    end
    return strikesresolved
end
