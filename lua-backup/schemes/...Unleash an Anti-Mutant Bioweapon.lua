function onLoad()   
    manipulations_stacked = 0
    
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs",
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function revealScheme()
    local manipulations = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])[1]
    if manipulations then
        manipulations_stacked = math.abs(manipulations.getQuantity())
    end
end

function bioweapon(params)
    countdown = countdown - 1
    if params and params.id then
        madechoices[params.id] = true
    end
    if countdown == 0 then
        for i,o in pairs(madechoices) do
            if o == true then
                for _,h in pairs(hqguids) do
                    local hero = getObjectFromGUID(h).Call('getHeroUp')
                    if hero and hero.hasTag(i) then
                        getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
                        Wait.time(function() getObjectFromGUID(h).Call('click_draw_hero') end,1)
                    end
                end
            end
        end
    end
end

function resolveTwist(params) 
    local cards = params.cards
    
    manipulations_stacked = manipulations_stacked + 1
    cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
    
    madechoices = {["Cost:2"] = false,
                ["Cost:3"] = false,
                ["Cost:4"] = false,
                ["Cost:5"] = false,
                ["Cost:6"] = false}
    
    if manipulations_stacked >= 5 then
        countdown = 1
        for i,_ in pairs(madechoices) do
            madechoices[i] = true
        end
        bioweapon()
    else
        countdown = manipulations_stacked
        getObjectFromGUID(pushvillainsguid).Call('offerChoice',{color = Turns.turn_color,
            choices = {["Cost:2"] = "2",
                ["Cost:3"] = "3",
                ["Cost:4"] = "4",
                ["Cost:5"] = "5",
                ["Cost:6"] = "6"},
            fsourceguid = self.guid,
            resolve_function = 'bioweapon',
            n = manipulations_stacked})
    end
    return nil
end