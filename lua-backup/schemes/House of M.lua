function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "schemeZoneGUID"
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

function nonTwist(params)
    if params.obj.getName() == "Scarlet Witch (R)" then
        obj.addTag("Power:" .. hasTag2(params.obj,"Cost:"))
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
            getObjectFromGUID(pushvillainsguid).Call('updateVar',{varname = "noMoreMutants",
                value = true})
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