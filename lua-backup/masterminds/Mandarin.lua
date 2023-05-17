function onLoad()
    local guids1 = {
        "pushvillainsguid"
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

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function moveToCity(params)
    params.obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
    Wait.time(click_push_villain_into_city,2)
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    local top = nil
    if epicness then
        top = true
    end
    for _,o in pairs(Player.getPlayers()) do
        local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])
        
        if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
            local vpilestrong = {}
            for _,o in pairs(vpilecontent[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k == "Group:Mandarin's Rings" then
                        table.insert(vpilestrong,o.guid)
                        break
                    end
                end
            end
            --log(vpilestrong)
            if vpilestrong[1] and not vpilestrong[2] then
                local pushDelayed = function()
                    Wait.time(click_push_villain_into_city,2)
                end
                vpilecontent[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    smooth = true,
                    guid = vpilestrong[1],
                    callback_function = pushDelayed})
            elseif vpilestrong[1] and vpilestrong[2] then
                getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                    pile = vpilecontent[1],
                    guids = vpilestrong,
                    resolve_function = 'moveToCity',
                    args = "self",
                    tooltip = "Push this Mandarin's Ring into the city.",
                    label = "Push",
                    fsourceguid = self.guid})
            else
                getObjectFromGUID(pushvillainsguid).Call('click_get_wound2',{color = o.color,top = top})
            end
        elseif vpilecontent[1] and vpilecontent[1].tag == "Card" then
            if vpilecontent[1].hasTag("Group:Mandarin's Rings") then
                moveToCity(vpilecontent[1])
            else
                getObjectFromGUID(pushvillainsguid).Call('click_get_wound2',{color = o.color,top = top})
            end
        else
            getObjectFromGUID(pushvillainsguid).Call('click_get_wound2',{color = o.color,top = top})
        end
    end
    return strikesresolved
end
