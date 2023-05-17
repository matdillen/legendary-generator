function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            broadcastToColor("Master Strike: KO a villain from your victory pile or gain a wound.",i,i)
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',(o)
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                local bsguids = {}
                for _,k in pairs(vpilecontent[1].getObjects()) do
                    local vp = 0
                    for _,l in pairs(k.tags) do                            
                        if l == "Villain" then
                            table.insert(bsguids,k.guid)
                            break
                        end
                    end
                end
                if #bsguids > 1 then
                    getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = i,
                        pile = vpilecontent[1],
                        guids = bsguids,
                        resolve_function = 'koCard',
                        tooltip = "KO this card.",
                        label = "KO"})
                elseif bsguids[1] then
                    vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                        smooth = false,
                        guid = bsguids[1]})
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                end
            elseif vpilecontent[1] and vpilecontent[1].hasTag("Villain") then
                getObjectFromGUID(pushvillainsguid).Call('koCard',vpilecontent[1])
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',i)
            end
        end
    end
    return strikesresolved
end
