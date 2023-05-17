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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    broadcastToAll("Scheme Twist: All heroes in the HQ KO'd")
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
            getObjectFromGUID(o).Call('click_draw_hero')
        end
    end
    return twistsresolved
end
