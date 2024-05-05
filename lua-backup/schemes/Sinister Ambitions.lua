function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "ambPileGUID",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function setupSpecial(params)
    log("Add ambitions to villain deck.")
    local ambPile = getObjectFromGUID(ambPileGUID)
    ambPile.randomize()
    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
    pos.y = pos.y + 2
    local annotateAmbition = function(obj)
        obj.setName("Ambition")
        obj.addTag("Ambition")
        obj.addTag("VP4")
        obj.setDescription("When this Ambition villain escapes, do its Ambition effect.")
    end
    for i=1,10 do
        pos.y = pos.y + i/7
        ambPile.takeObject({position=pos,
            flip=false,
            smooth=false,
            callback_function=annotateAmbition})
    end
    return {["villdeckc"] = 10}
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
                            currentZone = getObjectFromGUID(o),
                            targetZone = getObjectFromGUID(escape_zone_guid),
                            enterscity = 0})
                        broadcastToAll("Scheme Twist: Ambition villain escapes!")
                        break
                    end
                end
            end
        end
    end
    return nil
end