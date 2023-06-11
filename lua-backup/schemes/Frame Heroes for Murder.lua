function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
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
    
    if twistsresolved < 7 then
        local costs = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
        local incriminating = {}
        if costs[1] and costs[1].tag == "Deck" then
            for _,o in pairs(costs[1].getObjects()) do
                for _,t in pairs(o.tags) do
                    if t:find("Cost:") then
                        table.insert(incriminating,tonumber(t:sub(6)))
                        break
                    end
                end
            end
        elseif costs[1] then
            table.insert(incriminating,hasTag2(costs[1],"Cost:"))
        end
        local herotooffer = {}
        for i,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if not hero then
                return nil
            end
            herotooffer[i] = hero
            local addthishero = true
            for _,c in pairs(incriminating) do
                if hasTag2(hero,"Cost:") == c then
                    addthishero = false
                    break
                end
            end
            if not addthishero then
                herotooffer[i] = nil
            end
        end
        if #herotooffer > 1 then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
                hand = herotooffer,
                pos = getObjectFromGUID(twistZoneGUID).getPosition(),
                label = "Frame",
                tooltip = "Frame this hero for murder.",
                trigger_function = 'refreshHQ',
                args = "self",
                fsourceguid = self.guid})
        elseif #herotooffer > 0 then
            herotooffer[1].setPosition(getObjectFromGUID(twistZoneGUID).getPosition())
        end
    elseif twistsresolved == 7 then
        local herotooffer = {}
        for _,o in pairs(hqguids) do
            table.insert(herotooffer,getObjectFromGUID(o).Call('getHeroUp'))
        end
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = herotooffer,
            pos = getObjectFromGUID(twistZoneGUID).getPosition(),
            label = "Frame",
            tooltip = "Frame this hero for murder.",
            trigger_function = 'refreshHQ',
            args = "self",
            fsourceguid = self.guid})
    end
    return twistsresolved
end