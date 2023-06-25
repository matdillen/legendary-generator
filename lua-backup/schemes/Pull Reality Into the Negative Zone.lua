function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID",
        "villainDeckZoneGUID"
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

    local guids3 = {
        "attackguids",
        "resourceguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local city = params.city
    
    if twistsresolved % 2 == 0 and twistsresolved < 7 then
        broadcastToAll("Scheme Twist: Until next twist, heroes cost attack to recruit and enemies recruit to fight!")
        for _,o in pairs(hqguids) do
            local zone = getObjectFromGUID(o)
            zone.Call('updateVar3',{name = "resourceguids",
                value = attackguids})
            for i,b in pairs(zone.getButtons()) do
                if b.click_function == "click_buy_hero" then
                    zone.editButton({index = i-1,color = "Red"})
                    break
                end
            end
        end
        for _,o in pairs(city) do
            local zone = getObjectFromGUID(o)
            zone.Call('updateVar3',{name = "attackguids",
                value = resourceguids})
            for i,b in pairs(zone.getButtons()) do
                if b.click_function == "click_fight_villain" then
                    zone.editButton({index = i-1,color = "Yellow"})
                    break
                end
            end    
        end
    elseif twistsresolved < 7 and twistsresolved > 1 then
        broadcastToAll("Scheme Twist: Resource reversions are relieved!")
        for _,o in pairs(hqguids) do
            local zone = getObjectFromGUID(o)
            zone.Call('updateVar3',{name = "resourceguids",
                value = resourceguids})
            for i,b in pairs(zone.getButtons()) do
                if b.click_function == "click_buy_hero" then
                    zone.editButton({index = i-1,color = "Yellow"})
                    break
                end
            end
        end
        for _,o in pairs(city) do
            local zone = getObjectFromGUID(o)
            zone.Call('updateVar3',{name = "attackguids",
                value = attackguids})
            for i,b in pairs(zone.getButtons()) do
                if b.click_function == "click_fight_villain" then
                    zone.editButton({index = i-1,color = "Red"})
                    break
                end
            end    
        end
    elseif twistsresolved == 7 then
        broadcastToAll("Evil Wins!")
    end
    return twistsresolved
end