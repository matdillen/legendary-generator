function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
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

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    if twistsresolved > 2 and twistsresolved < 11 then
        getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
        local monsterpit = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
        local monsterpower = 0
        if monsterpit[1] then
            if monsterpit[1].tag == "Deck" then
                local monsterToEnter = monsterpit[1].getObjects()[1]
                for _,i in pairs(monsterToEnter.tags) do
                    if i:find("Power:") then
                        monsterpower = tonumber(i:match("%d+"))
                    end
                end
                monsterpit[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    flip=true,
                    callback_function = click_push_villain_into_city})
            else
                monsterpower = hasTag2(monsterpit[1],"Power:")
                monsterpit[1].flip()
                monsterpit[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                local lastMonsterSpawned = function()
                    local monster = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
                    if monster[1] and monster[1].guid == monsterpit[1].guid then
                        return true
                    else
                        return false
                    end   
                end
                Wait.condition(click_push_villain_into_city,lastMonsterSpawned)
            end
        end
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
                local maxpower = 0
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    local vpilecards = vpilecontent[1].getObjects()
                    for _,j in pairs(vpilecards) do
                        for _,tag in pairs(j.tags) do
                            if tag:find("Power:") then
                                maxpower = math.max(maxpower,tonumber(tag:match("%d+")))
                                break
                            end
                        end
                    end
                elseif vpilecontent[1] then
                    if hasTag2(vpilecontent[1],"Power:") then
                        maxpower = hasTag2(vpilecontent[1],"Power:")
                    end
                end
                if monsterpower > maxpower then
                    broadcastToAll("Player " .. i .. "'s best Gladiator was no good (power of only " .. maxpower .. ") and they got a wound!",i)
                    getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                end
            end
        end
        return nil
    else
        return twistsresolved
    end
end