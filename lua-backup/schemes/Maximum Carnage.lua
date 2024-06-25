function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "bszoneguid",
        "escape_zone_guid",
        "woundszoneguid"
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

function bonusInCity(params)
    if params.object.hasTag("Possessed") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{label = "+" .. params.twistsstacked,
            zoneguid = params.zoneguid,
            tooltip = "This Possessed bystander has power equal to the number of twists stacked next to the scheme.",
            id="twistsstacked"})
    end
end

function possessedPsychotic(obj)
    obj.addTag("Possessed")
    obj.addTag("Villain")
    obj.addTag("Power:0")
    obj.removeTag("Bystander")
    Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('updatePower') end,0.5)
end

function fightEffect(params)
    params.obj.addTag("Bystander")
    params.obj.removeTag("Villain")
    params.obj.removeTag("Possessed")
    params.obj.removeTag("Power:0")
end

function setupCounter(init)
    if init then
        return {["zoneguid2"] = woundszoneguid,
                ["tooltip"] = "Bystanders escaped: __/6.",
                ["tooltip2"] = "Wounds stack count: __."}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Bystander"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Bystander") then
            counter = counter + 1
        end
        return counter
    end
end

function setupCounter2()
    local vildeck = Global.Call('get_decks_and_cards_from_zone',woundszoneguid)[1]
    if vildeck then
        return math.abs(vildeck.getQuantity())
    else
        return 0
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
    bsPile.takeObject({position = getObjectFromGUID(city_zones_guids[5]).getPosition(),
        flip=true,
        callback_function = possessedPsychotic})
    return nil
end