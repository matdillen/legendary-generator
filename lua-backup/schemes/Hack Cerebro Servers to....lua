function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "bystandersPileGUID",
        "bszoneguid",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids",
        "topBoardGUIDs"
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

function refreshHQ(params)
    getObjectFromGUID(hqguids[params.index]).Call('click_draw_hero')
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards

    local kidnappedmutants = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    local hackers = 0
    if kidnappedmutants[1] then
        hackers = math.abs(kidnappedmutants[1].getQuantity())
    end
    local bsdeck = getObjectFromGUID(bystandersPileGUID)
    if twistsresolved < 6 then
        bsdeck.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
            flip = false,
            smooth = true})
        local hq_cards = {}
        for i,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            table.insert(hq_cards,hero)
            if not hasTag2(hero,"Cost:") or hasTag2(hero,"Cost:") ~= hackers + 1 then
                hq_cards[i] = nil
            end
        end
        if hq_cards[1] then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
                hand = hq_cards,
                pos = getObjectFromGUID(kopile_guid).getPosition(),
                label = "KO",
                tooltip = "KO this hero.",
                trigger_function = 'refreshHQ',
                args = "self",
                fsourceguid = self.guid})
            cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
            return nil
        end
    elseif twistsresolved == 6 then
        if kidnappedmutants[1] then
            Global.Call('bump',{obj = bsdeck})
            kidnappedmutants[1].setPositionSmooth(getObjectFromGUID(bszoneguid).getPosition())
        end
        getObjectFromGUID(pushvillainsguid).Call('unveilScheme',self)
        return nil
    end
    return twistsresolved
end