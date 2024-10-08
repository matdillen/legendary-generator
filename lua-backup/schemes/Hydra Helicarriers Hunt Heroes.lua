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

function koColor(params)
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and hero.hasTag("HC:" .. params.id) then
            getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
            if params.n == 0 then
                getObjectFromGUID(o).Call('click_draw_hero')
            end
        elseif not hero and params.n == 0 then
            getObjectFromGUID(o).Call('click_draw_hero')
        end
    end
end

function setupCounter(init)
    if init then
        return {["zoneguid"] = kopile_guid,
                ["tooltip"] = "KO'd nongrey heroes: __/18."}
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
    if twistsresolved < 5 then
        broadcastToAll("Scheme Twist: Choose " .. twistsresolved .. " different Hero Classes and each hero in the HQ that is any of them will be KO'd.",{1,1,1})
        getObjectFromGUID(pushvillainsguid).Call('offerChoice',{color = Turns.turn_color,
            choices = {["Blue"] = "Blue",
                ["Green"] = "Green",
                ["Red"] = "Red",
                ["Silver"] = "Silver",
                ["Yellow"] = "Yellow"},
            fsourceguid = self.guid,
            resolve_function = 'koColor',
            n = twistsresolved,
            choicecolors = {["Blue"] = "Blue",
                ["Green"] = "Green",
                ["Red"] = "Red",
                ["Silver"] = "White",
                ["Yellow"] = "Yellow"}})
    else
        broadcastToAll("Scheme Twist: All heroes in the HQ with a hero class KO'd!")
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            --log(hero)
            if hero and hasTag2(hero,"HC:",4) then
                getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
                getObjectFromGUID(o).Call('click_draw_hero')
            end
        end
    end
    return nil
end