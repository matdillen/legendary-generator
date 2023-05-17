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
    local sunlight = 0
    local moonlight = 0
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            local cost = hasTag2(hero,"Cost:")
            if cost then
                if cost % 2 == 0 then
                    sunlight = sunlight + 1
                else
                    moonlight = moonlight + 1
                end
            end
        end
    end
    local light = sunlight - moonlight
    if twistsresolved < 9 then
        if (light < 0 and twistsresolved % 2 == 1) or (light > 0 and twistsresolved % 2 == 0) then
            cards[1].setName("Altered Orbit")
            getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
            broadcastToAll("Scheme Twist caused an Altered Orbit!",{1,0,0})
        else
            getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
            broadcastToAll("Scheme Twist, but the light aligned!",{0,1,0})
        end
    elseif twistsresolved < 12 then
        cards[1].setName("Altered Orbit")
        getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
        broadcastToAll("Scheme Twist caused an Altered Orbit!",{1,0,0})
    end
    return nil
end