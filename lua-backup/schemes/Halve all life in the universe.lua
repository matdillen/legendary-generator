function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "heroDeckZoneGUID"
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

function refreshHero(params)
    getObjectFromGUID(hqguids[params.index]).Call('click_draw_hero')
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    local pos = getObjectFromGUID(kopile_guid).getPosition()
    pos.y = pos.y + 2
    if twistsresolved == 1 or twistsresolved == 3 or twistsresolved == 5 then
        local herosnap = {}
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                table.insert(herosnap,hero)
            else
                broadcastToAll("Missing hero in the HQ?")
                return nil
            end
        end
        broadcastToAll("Scheme Twist: KO three heroes from the HQ!")
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = herosnap,
            pos = pos,
            label = "KO",
            tooltip = "KO this hero.",
            trigger_function = 'refreshHero',
            args = "self",
            fsourceguid = self.guid})
    elseif twistsresolved == 2 or twistsresolved == 4 then
        local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1]
        local cut = herodeck.cut()
        cut[1].setPosition(pos)
        broadcastToAll("Scheme Twist: Half of the hero deck is KO'd!")
    end
    return twistsresolved
end