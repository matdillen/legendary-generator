function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "heroDeckZoneGUID",
        "setupguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)
    local kopilepos = getObjectFromGUID(kopile_guid).getPosition()
    if herodeck[1] and herodeck[1].tag == "Deck" then
        local phoenixDevours = function(obj)
            if hasTag2(obj,"HC:") and not hasTag2(obj,"HC:")[2] then
                broadcastToAll("Master Strike: Dark Phoenix purges the whole hero deck of hero class " .. hasTag2(obj,"HC:") .. "!")
            elseif hasTag2(obj,"HC:") then
                broadcastToAll("Master Strike: Dark Phoenix purges the whole hero deck of hero class " .. hasTag2(obj,"HC:")[1] .. " and " .. hasTag2(obj,"HC:")[2] .. "!")
            else
                broadcastToAll("Master Strike: The hero just KO'd had no hero class? Scripted strike failed.")
                return nil
            end
            local koguids = {}
            local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)
            if herodeck[1] and herodeck[1].tag == "Deck" then
                for i,o in ipairs(herodeck[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        local tag = k
                        if k:find("HC1:") or k:find("HC2:") then
                            tag = k:gsub("HC.:","HC:")
                        end
                        if (not hasTag2(obj,"HC:")[1] and tag == "HC:" .. hasTag2(obj,"HC:")) or 
                            (hasTag2(obj,"HC:")[1] and (tag == "HC:" .. hasTag2(obj,"HC:")[1] or 
                                tag == "HC:" .. hasTag2(obj,"HC:")[2])) then
                            table.insert(koguids,i)
                            break
                        end
                    end
                end
                if koguids[1] then
                    local remo = 0
                    for i = 1,#koguids do
                        herodeck[1].takeObject({position = kopilepos,
                            flip=true,
                            smooth=true,
                            index = koguids[i]-1-remo})
                        remo = remo + 1
                        if herodeck[1].remainder then
                            local remains = herodeck[1].remainder
                            remains.flip()
                            if hasTag2(remains,"HC:") == hasTag2(obj,"HC:") then
                                getObjectFromGUID(pushvillainsguid).Call('koCard',remains)
                            end
                            if hasTag2(remains,"HC:")[1] or hasTag2(obj,"HC:")[1] then
                                for _,h1 in pairs(hasTag2(remains,"HC:")) do
                                    for _,h2 in pairs(hasTag2(obj,"HC:")) do
                                        if h1 == h2 then
                                            getObjectFromGUID(pushvillainsguid).Call('koCard',remains)
                                            remo = -1
                                            break
                                        end
                                    end
                                    if remo == -1 then
                                        break
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            elseif herodeck[1] and 
                (not hasTag2(obj,"HC:")[1] and herodeck[1].hasTag("HC:" .. hasTag2(obj,"HC:"))) or 
                    (hasTag2(obj,"HC:")[1] and 
                    (herodeck[1].hasTag("HC:" .. hasTag2(obj,"HC:")[1]) or 
                        herodeck[1].hasTag("HC:" .. hasTag2(obj,"HC:")[2]))) then
                herodeck[1].flip()
                getObjectFromGUID(pushvillainsguid).Call('koCard',herodeck[1])
            end
        end
        herodeck[1].takeObject({position = kopilepos,
            flip=true,
            smooth=true,
            callback_function = phoenixDevours})
    elseif herodeck[1] then
        herodeck[1].flip()
        getObjectFromGUID(pushvillainsguid).Call('koCard',herodeck[1])
        broadcastToAll("Master Strike: Dark Phoenix purges the whole hero deck!")
    else
        broadcastToAll("Master Strike: The hero deck ran out so Dark Phoenix wins!")
    end
    if epicness == true then
        getObjectFromGUID(setupGUID).Call('playHorror')
        broadcastToAll("Each player must play a Hellfire Club villain from their Victory Pile!")       
    end
    return strikesresolved
end