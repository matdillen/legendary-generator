function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function bonusInCity(params)
    if params.object.hasTag("Ambition") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object,
            label = "+" .. params.twistsstacked,
            id = "twistsstacked",
            tooltip = "This ambition card is a villain with power equal to its ambition value + the number of twists stacked next to the scheme. Resolve its ambition effect if it escapes.",
            zoneguid = params.zoneguid})
    end
end

function nonTwist(params)
    local obj = params.obj
    
    if obj.hasTag("Ambition") then
        obj.addTag("Villain")
        obj.addTag("VP4")
    end
    return 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved < 6 then
        getObjectFromGUID(pushvillainsguid).Call('updatePower')
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    elseif twistsresolved == 6 then
        getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
        for _,o in pairs(city) do
            local citycards = Global.Call('get_decks_and_cards_from_zone',o)
            if citycards[1] then
                for _,o in pairs(citycards) do
                    if o.hasTag("Ambition") then
                        getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = citycards,
                            targetZone = getObjectFromGUID(escape_zone_guid),
                            enterscity = 0,
                            schemeParts = {self.getName()}})
                        broadcastToAll("Scheme Twist: Ambition villain escapes!")
                        break
                    end
                end
            end
        end
    end
    return nil
end