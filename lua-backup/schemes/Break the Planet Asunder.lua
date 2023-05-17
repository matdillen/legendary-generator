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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        local attack = 0
        if hero then
            if not hasTag2(hero,"Attack:") or hasTag2(hero,"Attack:") < twistsstacked then
                getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
                getObjectFromGUID(o).Call('click_draw_hero')
                broadcastToAll("Scheme Twist! Weak hero " .. hero.getName() .. " KO'd from HQ!")
            end
        else
            broadcastToAll("Hero missing in hq!")
            return nil
        end
    end
    return nil
end