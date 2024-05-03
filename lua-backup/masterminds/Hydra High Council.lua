function onLoad()
    mmname = "Hydra High Council"
    
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "mmZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids",
        "hqguids"
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

function updateMMHydraHigh()
    local mm = Global.Call('get_decks_and_cards_from_zone',mmloc.guid)
    local name = nil
    local power = 0
    if mm[1] and mm[1].tag == "Deck" then
        local mmdata = mm[1].getObjects()[mm[1].getQuantity()]
        name = mmdata.name
        for _,t in pairs(mmdata.tags) do
            if t:find("Power:") then
                power = tonumber(t:match("%d+"))
                break
            end
        end
    elseif mm[1] then
        name = mm[1].getName()
        power = hasTag2(mm[1],"Power:")
    end
    if not name then
        return nil
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = name,
        checkvalue = 1,
        label = power,
        tooltip = "Base power as written on the card.",
        f = 'updatePower',
        id = 'card'})
    if name == "Baron Helmut Zemo" then
        local color = Turns.turn_color
        local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[color])
        local savior = 0
        if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
            for _,k in pairs(vpilecontent[1].getObjects()) do
                for _,l in pairs(k.tags) do
                    if l == "Villain" then
                        savior = savior + 1
                        break
                    end
                end
            end
        elseif vpilecontent[1] then
            if vpilecontent[1].hasTag("Villain") then
                savior = 1
            end
        end
        getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
            checkvalue = savior,
            label = "-" .. savior,
            tooltip = "The Baron gets -1 for each villain in your victory pile.",
            f = 'updateMMHydraHigh',
            id = "hydracouncil",
            f_owner = self})
    elseif name == "Viper" then
        local shiarfound = 0
        for i=2,#city_zones_guids do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[i])
            if citycontent[1] then
                for _,o in pairs(citycontent) do
                    if o.getName():upper():find("HYDRA") or (hasTag2(o,"Group:") and hasTag2(o,"Group:"):upper():find("HYDRA")) then
                        shiarfound = shiarfound + 1
                        break
                    end
                end
            end
        end
        getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
            checkvalue = shiarfound,
            label = "+" .. shiarfound,
            tooltip = "Viper gets +1 for each HYDRA Villain in the city.",
            f = 'updateMMHydraHigh',
            id = "hydracouncil",
            f_owner = self})
    elseif name == "Red Skull" then
        local shiarfound = 0
        local escapezonecontent = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escapezonecontent[1] and escapezonecontent[1].tag == "Deck" then
            for _,o in pairs(escapezonecontent[1].getObjects()) do
                if o.name:upper():find("HYDRA") then
                    shiarfound = shiarfound + 1
                elseif next(o.tags) then
                    for _,tag in pairs(o.tags) do
                        if tag:upper():find("HYDRA") or tag == "Starter" or tag == "Officer" then
                            shiarfound = shiarfound + 1
                            break
                        end
                    end
                end
            end
        elseif escapezonecontent[1] then
            if escapezonecontent[1].getName():upper():find("HYDRA") or 
                (hasTag2(escapezonecontent[1],"Group:") and hasTag2(escapezonecontent[1],"Group:"):upper():find("HYDRA")) or 
                escapezonecontent[1].hasTag("Starter") or 
                escapezonecontent[1].hasTag("Officer") then
                shiarfound = shiarfound + 1
            end
        end
        shiarfound = shiarfound/2 - 0.5*(shiarfound % 2)
        getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
            checkvalue = shiarfound,
            label = "+" .. shiarfound,
            tooltip = "Red Skull gets +1 for each two HYDRA levels.",
            f = 'updateMMHydraHigh',
            id = "hydracouncil",
            f_owner = self})
    elseif name == "Arnim Zola" then
        local power = 0
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                for _,k in pairs(hero.getTags()) do
                    if k:find("Attack:") or k:find("Attack1:") or k:find("Attack2:") then
                        power = power + tonumber(k:match("%d+"))
                    end
                end
            end
        end
        getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
            checkvalue = power,
            label = "+" .. power,
            tooltip = "Arnim Zola gets extra Attack equal to the total printed Attack of all heroes in the HQ.",
            f = 'updateMMHydraHigh',
            id = "hydracouncil",
            f_owner = self})
    end
end

function setupMM()
    mmloc = getObjectFromGUID(getObjectFromGUID(mmZoneGUID).Call('returnMMLocation',mmname))
    
    updateMMHydraHigh()
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMHydraHigh,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMHydraHigh,0.1)
    end
    function onPlayerTurn(player,previous_player)
        updateMMHydraHigh()
    end
end

function fightEffect(params)
    if params.mm then
        Wait.time(updateMMHydraHigh,1)
    end
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