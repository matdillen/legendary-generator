function onLoad()   
    twistsstacked = 0
    
    local guids1 = {
        "pushvillainsguid"
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

function explode_heroes(zone,n)
    local currenthero = nil
    local explode_hero = function()
        local hero = getObjectFromGUID(zone).Call('getHeroUp')
        if hero then
            currenthero = hero
            local hq_cards = getObjectFromGUID(zone).Call('getHeroDown')
            hero.flip()
            if not hq_cards or hq_cards.getQuantity() < 5 then
                getObjectFromGUID(zone).Call('click_draw_hero')
            end
        else
            printToAll("Error: hero not found in HQ.",{1,0,0})
        end
    end
    local hero_drawn = function()
        if not currenthero then
            return true
        end
        local hero = getObjectFromGUID(zone).Call('getHeroUp')
        if hero then
            if hero.guid == currenthero.guid then
                return false
            else
                return true
            end
        else
            return false
        end
    end
    for i=1,n do
        Wait.condition(explode_hero,hero_drawn)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    local heroboom = 0
    broadcastToAll("Scheme Twist: " .. twistsstacked .. " heroes will be KO'd from the HQ!")
    while heroboom < twistsstacked do
        local boomstack = nil
        local hq_cards = getObjectFromGUID(hqguids[1]).Call('getHeroDown')
        if hq_cards then
            boomstack_count = math.abs(hq_cards.getQuantity())
        else
            boomstack_count = 0
        end
        if boomstack_count > 5 then
            table.remove(hqguids,1)
        else
            local todestroy = math.min(6-boomstack_count,twistsresolved-heroboom)
            explode_heroes(hqguids[1],todestroy)
            heroboom = heroboom + todestroy
            if heroboom < twistsresolved then
                table.remove(hqguids,1)
            end
        end
        if not hqguids[1] then
            broadcastToAll("Helicarrier destroyed!!!",{1,0,0})
            return nil
        end
    end
    return nil
end