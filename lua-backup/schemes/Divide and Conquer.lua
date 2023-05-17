function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS",
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

function koThisHeroDeck(params)
    local content = Global.Call('get_decks_and_cards_from_zone',params.obj.guid)[1]
    content.flip()
    getObjectFromGUID(pushvillainsguid).Call('koCard',content)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    if twistsresolved < 4 then
        for _,o in pairs(hqguids) do
            local hqzone = getObjectFromGUID(o)
            local herocard = hqzone.Call('getHeroUp')
            if herocard then
                herocard.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                hqzone.Call('click_draw_hero')
            end
        end
        broadcastToAll("Scheme Twist: All heroes in HQ KO'd!")
    else
        broadcastToAll("Scheme Twist: KO one of the hero decks!!",{1,0,0})
        local divdeckzones = {}
        for i=7,11 do
            local deck = Global.Call('get_decks_and_cards_from_zone',allTopBoardGUIDS[i])[1]
            if deck then
                table.insert(divdeckzones,getObjectFromGUID(allTopBoardGUIDS[i]))
            end
        end

        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = table.clone(divdeckzones),
            pos = "Stay",
            label = "KO",
            tooltip = "KO this hero deck.",
            trigger_function = 'koThisHeroDeck',
            args = "self",
            isZone = true,
            fsourceguid = self.guid})
    end
    return twistsresolved
end