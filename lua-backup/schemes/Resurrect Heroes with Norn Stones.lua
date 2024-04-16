function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
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

function pushToBridge(params)
    local pos = getObjectFromGUID(city_zones_guids[6]).getPosition()
    pos.y = pos.y + 2
    params.obj.setPositionSmooth(pos)
end

function pushToEscape(params)
    local pos = getObjectFromGUID(escape_zone_guid).getPosition()
    pos.y = pos.y + 2
    params.obj.setPositionSmooth(pos)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    if twistsresolved < 7 then
        local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[Turns.turn_color])[1]
        local villains = {}
        local pos = getObjectFromGUID(city_zones_guids[6]).getPosition()
        pos.y = pos.y + 2
        if vpile and vpile.tag == "Deck" then
            for _,o in pairs(vpile.getObjects()) do
                for _,tag in pairs(o.tags) do
                    if tag == "Villain" then
                        table.insert(villains,o.guid)
                        break
                    end
                end
            end
            if villains[1] then
                local cityobjects = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[6])
                if cityobjects[1] then
                    getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = cityobjects,
                        targetZone = getObjectFromGUID(escape_zone_guid),
                        enterscity = 0})
                end
                if villains[2] then
                    offerCards({color = Turns.turn_color,
                        pile = vpile,
                        guids = villains,
                        resolve_function = 'pushToBridge',
                        tooltip = "This villain enters the Bridge!",
                        label = "Push",
                        fsourceguid = self.guid})
                else
                    vpile.takeObject({position = pos,
                        smooth = true})
                end
            end
        elseif vpile and vpile.hasTag("Villain") then
            local cityobjects = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[6])
            if cityobjects[1] then
                getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = cityobjects,
                    targetZone = getObjectFromGUID(escape_zone_guid),
                    enterscity = 0})
            end
            vpile.setPositionSmooth(pos)
        end
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    elseif twistsresolved < 9 then
        local pos = getObjectFromGUID(escape_zone_guid).getPosition()
        pos.y = pos.y + 2
        for _,p in pairs(Player.getPlayers()) do
            local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[p.color])[1]
            local villains = {}
            if vpile and vpile.tag == "Deck" then
                for _,o in pairs(vpile.getObjects()) do
                    for _,tag in pairs(o.tags) do
                        if tag == "Villain" then
                            table.insert(villains,o.guid)
                            break
                        end
                    end
                end
                if villains[1] then
                    if villains[2] then
                        offerCards({color = p.color,
                            pile = vpile,
                            guids = villains,
                            resolve_function = 'pushToEscape',
                            tooltip = "This villain is put into the escape pile!",
                            label = "Escape",
                            fsourceguid = self.guid})
                    else
                        vpile.takeObject({position = pos,
                            smooth = true})
                    end
                end
            elseif vpile and vpile.hasTag("Villain") then
                vpile.setPositionSmooth(pos)
            end
        end
    end
    return twistsresolved
end