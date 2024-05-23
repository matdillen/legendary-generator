function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "schemeZoneGUID",
        "heroPileGUID",
        "villainDeckZoneGUID",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function setupSpecial(params)
    log("Scarlet Witch in villain deck.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = "Scarlet Witch (R)",
        pileGUID = heroPileGUID,
        destGUID = villainDeckZoneGUID})
    return {["villdeckc"] = 14}
end

function bonusInCity(params)
    if params.object.hasTag("Scarlet Witch") then
        local boost = 3
        if noMoreMutants then
            boost = 4
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object,
            label = "+" .. boost,
            zoneguid = params.zoneguid,
            tooltip = "This Scarlet Witch villain gets +" .. boost .. ".",
            id = "scarletwitch"})
    end
end

function nonTwist(params)
    local obj = params.obj
    if obj.getName() == "Scarlet Witch (R)" then
        obj.addTag("Power:" .. hasTag2(obj,"Cost:"))
        obj.addTag("Villain")
        obj.addTag("Scarlet Witch")
    end
    return 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local city = params.city

    if not noMoreMutants then
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                if hasTag2(hero,"Team:",6) and hasTag2(hero,"Team:",6) ~= "X-Men" then
                    getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
                    broadcastToAll("Sapiens hero KO'd from the HQ!")
                    getObjectFromGUID(o).Call('click_draw_hero')
                end
            end
        end
        local scarletWitchCount = 0
        for _,o in pairs(city) do
            local citycards = Global.Call('get_decks_and_cards_from_zone',o)
            if citycards[1] then
                for _,k in pairs(citycards) do
                    if k.getName() == "Scarlet Witch (R)" then
                        scarletWitchCount = scarletWitchCount +1
                    end
                end
            end
        end
        if scarletWitchCount > 1 then
            self.flip()
            noMoreMutants = true
            broadcastToAll("Scheme Twist: The Scheme transforms! No More Mutants!")
        else
            getObjectFromGUID(pushvillainsguid).Call('click_draw_villain')
        end
    else
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                if hasTag2(hero,"Team:",6) and hasTag2(hero,"Team:",6) == "X-Men" then
                    getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
                    getObjectFromGUID(o).Call('click_draw_hero')
                    broadcastToAll("Mutant hero KO'd from the HQ!")
                end
            end
        end 
        getObjectFromGUID(pushvillainsguid).Call('click_draw_villain')
    end
    return twistsresolved
end