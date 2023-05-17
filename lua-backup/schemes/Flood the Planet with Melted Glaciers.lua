function onLoad()   
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
    
    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    broadcastToAll("Scheme Twist: Heroes that are too cheap will drown and be KO'd from the HQ!")
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            if hasTag2(hero,"Cost:") <= twistsresolved then
                getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
                getObjectFromGUID(o).Call('click_draw_hero')
                broadcastToAll("Scheme Twist! Cheap hero " .. hero.getName() .. " drowned and was KO'd from the HQ!")
            end
        else
            broadcastToAll("Hero missing in hq!")
            return nil
        end
    end
    return nil
end