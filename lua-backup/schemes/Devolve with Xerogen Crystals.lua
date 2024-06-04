function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID",
        "setupGUID",
        "villainDeckZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids",
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function nonTwist(params)
    local obj = params.obj
    
    local schemeParts = table.clone(getObjectFromGUID(setupGUID).Call('returnVar',"setupParts"))
    
    if obj.getName() == schemeParts[9] or (hasTag2(obj,"Group:") and hasTag2(obj,"Group:") == schemeParts[9]) then
        obj.setName("Xerogen Experiments")
        if obj.getDescription() == "" then
            obj.setDescription("ABOMINATION: Villain gets extra printed Power from hero below it in the HQ.")
        else
            obj.setDescription(obj.getDescription() .. "\r\nABOMINATION: Villain gets extra printed Power from hero below it in the HQ.")
        end
    end
    return 1
end

function bonusInCity(params)
    if params.object.getName() == "Xerogen Experiments" then
        local hqguid = nil
        for i,o in pairs(city_zones_guids) do
            if o == params.zoneguid then
                hqguid = hqguids[7-i]
                break
            end
        end
        local bonus = 0
        if hqguid then
            local hero = getObjectFromGUID(hqguid).Call('getHeroUp')
            if hero and hasTag2(hero,"Attack:") then
                bonus = hasTag2(hero,"Attack:") 
            end
        else
            broadcastToAll("ERROR: HQ zone for city space " .. params.zoneguid .. "  not found??")
            return nil
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object, 
            label = "+" .. bonus,
            zoneguid = params.zoneguid,
            tooltip = "This villain gets +1 extra printed Power from hero below it in the HQ.",
            id="xerogencrystal"})
    end
end

function fillHQ(params)
    Global.Call('bump',{obj = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1],y = 5})
    getObjectFromGUID(hqguids[params.index]).Call('click_draw_hero')
end

function setupCounter(init)
    if init then
        local playercounter = 3*#Player.getPlayers()
        return {["tooltip"] = "Villains escaped: __/" .. playercounter .. ".",
                ["zoneguid"] = escape_zone_guid,
                ["tooltip2"] = "Villain deck count: __.",
                ["zoneguid2"] = villainDeckZoneGUID}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Villain"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Villain") then
            counter = counter + 1
        end
        return counter
    end
end

function setupCounter2()
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck then
        return math.abs(vildeck.getQuantity())
    else
        return 0
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    broadcastToAll("Choose a Hero in the HQ that doesn't have a printed Power of 2 or more to be put on the bottom of the Hero Deck.")
    local heroes = {}
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then
            broadcastToAll("Missing hero in the HQ?")
            return nil
        end
        heroes[i] = hero
        if hasTag2(hero,"Attack:") and hasTag2(hero,"Attack:") > 1 then
            heroes[i] = nil
        end
    end
    if next(heroes) then
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = heroes,
            pos = getObjectFromGUID(heroDeckZoneGUID).getPosition(),
            flip = true,
            label = "Tuck",
            tooltip = "Put this hero on the bottom of the hero deck.",
            trigger_function = 'fillHQ',
            args = "self",
            fsourceguid = self.guid})
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    return twistsresolved
end