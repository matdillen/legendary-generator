function onLoad()
    mmname = "Deathbird"
    
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "escape_zone_guid",
        "mmZoneGUID"
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
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMDeathbird()
    local shiarfound = 0
    for i=2,#city_zones_guids do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[i])
        if citycontent[1] then
            for _,o in pairs(citycontent) do
                if o.getName():find("Shi'ar") or hasTag2(o,"Group:Shi'ar") then
                    shiarfound = shiarfound + 1
                    break
                end
            end
        end
    end
    local escapezonecontent = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
    for i = 1,2 do
        if escapezonecontent[i] and escapezonecontent[i].tag == "Deck" then
            for _,o in pairs(escapezonecontent[i].getObjects()) do
                if o.name:find("Shi'ar") then
                    shiarfound = shiarfound + 1
                elseif next(o.tags) then
                    for _,tag in pairs(o.tags) do
                        if tag:find("Shi'ar") then
                            shiarfound = shiarfound + 1
                            break
                        end
                    end
                end
            end
        elseif escapezonecontent[i] then
            if escapezonecontent[i].getName():find("Shi'ar") or hasTag2(escapezonecontent[i],"Group:Shi'ar") then
                shiarfound = shiarfound + 1
            end
        end
    end
    local modifier = 1
    if epicness then
        modifier = 2
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = shiarfound,
        label = "+" .. shiarfound*modifier,
        tooltip = "Deathbird gets +" .. modifier .. " for each Shi'ar Villain in the city and Escape Pile.",
        f = 'updateMMDeathbird',
        id = "shiarbonus",
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    updateMMDeathbird()
    
    function onObjectEnterZone(zone,object)
        if object.getName():find("Shi'ar") or object.hasTag("Group:Shi'ar Imperial Elite") or object.hasTag("Group:Shi'ar Imperial Guard") then
            Wait.time(updateMMDeathbird,0.1)
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.getName():find("Shi'ar") or object.hasTag("Group:Shi'ar Imperial Elite") or object.hasTag("Group:Shi'ar Imperial Guard") then
            Wait.time(updateMMDeathbird,0.1)
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city
    local epicness = params.epicness

    local shiarfound = false
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,p in pairs(citycontent) do
                if p.getName():find("Shi'ar") or hasTag2(p,"Group:Shi'ar") then
                    if epicness == true then
                        getObjectFromGUID(setupGUID).Call('playHorror')
                    else
                        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
                    end
                    shiarfound = true
                    break
                end
            end                 
        end
        if shiarfound then
            break
        end
    end
    if cards[1] then
        cards[1].setName("Shi'ar Battlecruiser")
        local attack = 0
        cards[1].addTag("Villain")
        if epicness == true then
            cards[1].addTag("VP6")
            attack = 9
        else
            cards[1].addTag("VP5")
            attack = 7
        end
        cards[1].addTag("Power:" .. attack)
        getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    end
    return nil
end