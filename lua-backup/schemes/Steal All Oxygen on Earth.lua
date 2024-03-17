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

function setupSpecial(params)
    setNotes(getNotes() .. "\r\n\r\n[9D02F9][b]Oxygen Level:[/b][-] 8")
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    broadcastToAll("Scheme Twist: The Oxygen level decreases to " .. 8-twistsstacked .. ". Any hero with cost greater than the oxygen level is KO'd from the HQ.")
    local notes = getNotes():gsub("Oxygen Level:%[/b%]%[%-%] %d+","Oxygen Level:[/b][-] " .. 8-twistsstacked,1)
    setNotes(notes)
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and hasTag2(hero,"Cost:") > 8 - twistsstacked then
            getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
            getObjectFromGUID(o).Call('click_draw_hero')
            broadcastToAll("Scheme Twist: " .. hero.getName() .. " suffocated and was KO'd")
        end
    end
    return nil
end
