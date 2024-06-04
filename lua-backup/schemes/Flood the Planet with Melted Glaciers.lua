function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
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

function setupCounter(init)
    if init then
        return {["zoneguid"] = kopile_guid,
                ["tooltip"] = "KO'd nongrey heroes: __/20."}
    else 
        local escaped = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        if escaped[1] then
            local counter = 0
            for _,o in pairs(escaped) do
                if o.tag == "Deck" then
                    local escapees = Global.Call('hasTagD',{deck = o,tag = "HC:",find=true})
                    if escapees then
                        counter = counter + #escapees
                    end
                elseif hasTag2(o,"HC:") then
                    counter = counter + 1
                end
            end
            return counter
        else
            return 0
        end
    end
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