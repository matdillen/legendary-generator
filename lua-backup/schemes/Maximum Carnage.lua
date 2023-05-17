function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "bszoneguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    local streetz = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[5])
    if streetz[1] then
        for _,o in pairs(streetz) do
            if o.hasTag("Villain") then
                getObjectFromGUID(pushvillainsguid).Call('dealWounds')
                Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('updatePower') end,2)
                return nil
            end
        end
    end
    local bsPile = Global.Call('get_decks_and_cards_from_zone',bszoneguid)[1]
    local possessedPsychotic = function(obj)
        obj.addTag("Possessed")
        obj.addTag("Villain")
        obj.removeTag("Bystander") -- complicates vp count!!
         getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = twistsstacked,
            tooltip = "This bystander has become possessed psychotic and is a villain with power equal to the number of stacked twists."})
        getObjectFromGUID(pushvillainsguid).Call('updatePower')
    end
    bsPile.takeObject({position = getObjectFromGUID(city_zones_guids[5]).getPosition(),
        flip=true,
        callback_function=possessedPsychotic})
    return nil
end
