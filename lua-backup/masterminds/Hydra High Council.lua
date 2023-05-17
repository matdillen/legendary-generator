function onLoad()
    local guids1 = {
        "pushvillainsguid",
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
    local city = params.city
    local mmloc = params.mmloc

    local mmcontent = Global.Call('get_decks_and_cards_from_zone',mmloc)
    local name = nil
    if mmcontent[1] and mmcontent[1].tag == "Deck" then
        name = mmcontent[1].getObjects()[mmcontent[1].getQuantity()].name
    elseif mmcontent[1] then
        name = mmcontent[1].getName()
    else
        broadcastToAll("Mastermind not found!")
        return nil
    end
    if name == "Viper" then
        broadcastToAll("Master Strike: If there are any Hydra Villains in the city, each player gains a Wound.")
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if string.lower(obj.getName()):find("hydra") or (hasTag2(obj,"Group:",7) and string.lower(hasTag2(obj,"Group:",7)):find("hydra")) then
                        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
                        mmcontent[1].randomize()
                        return strikesresolved
                    end
                end
            end
        end
    elseif name == "Red Skull" then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local handi = table.clone(hand)
            local iter = 0
            for i,obj in ipairs(handi) do
                if not hasTag2(obj,"HC:",4) then
                    table.remove(hand,i-iter)
                    iter = iter + 1
                end
            end
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = hand,
                pos = getObjectFromGUID(kopile_guid).getPosition(),
                label = "KO",
                tooltip = "KO this card."})
        end
        broadcastToAll("Master Strike: Each player KOs a non-grey Hero. Select one from your hand or you may also exchange it with one you have in play.")
    elseif name == "Baron Helmut Zemo" then
        broadcastToAll("Each player KOs a Hydra Villain from their Victory Pile or gains a Wound.")
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
                local vpilewarbound = {}
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,k in pairs(vpilecontent[1].getObjects()) do
                        if string.lower(k.name):find("hydra") then
                            table.insert(vpilewarbound,k.guid)
                        else
                            for _,tag in pairs(k.tags) do
                                if string.lower(tag):find("hydra") then 
                                    table.insert(vpilewarbound,k.guid)
                                    break
                                end
                            end
                        end
                    end
                    if vpilewarbound[1] and not vpilewarbound[2] then
                        vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                            smooth = true,
                            guid = vpilewarbound[1]})
                    elseif vpilewarbound[1] and vpilewarbound[2] then
                        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = i,
                            pile = vpilecontent[1],
                            guids = vpilewarbound,
                            resolve_function = 'koCard',
                            tooltip = "KO this villain.",
                            label = "KO"})
                        broadcastToColor("Master Strike: KO 1 of the " .. #vpilewarbound .. " villain cards that were put into play from your victory pile.",i,i)
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                    end
                elseif vpilecontent[1] then
                    --log(hasTag2(vpilecontent[1],"Group:",7,true))
                    if string.lower(vpilecontent[1].getName()):find("hydra") or (hasTag2(vpilecontent[1],"Group:") and string.lower(hasTag2(vpilecontent[1],"Group:")):find("hydra")) then
                        vpilecontent[1].setPosition(getObjectFromGUID(kopile_guid).getPosition())
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                    end
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                end
            end
        end
    elseif name == "Arnim Zola" then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local handi = table.clone(hand)
            local iter = 0
            for i,obj in ipairs(handi) do
                if not hasTag2(obj,"Attack:") then
                    table.remove(hand,i-iter)
                    iter = iter + 1
                end
            end
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = hand,
                n = 2})
        end
        broadcastToAll("Master Strike: Each player discards two heroes with Fight icons.")
    end
    mmcontent[1].randomize()
    return strikesresolved      
end
