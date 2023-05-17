function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
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
    local city = params.city

    if twistsresolved % 2 == 1 and twistsresolved < 10 then
        local id = math.modf(twistsresolved/2)
        if twistsresolved > 2 then
            getObjectFromGUID(fortifiedCityZoneGUID).clearButtons()
        end
        fortifiedCityZoneGUID = city_zones_guids[6 - id]
        local fortifiedCityZone = getObjectFromGUID(fortifiedCityZoneGUID)
        fortifiedCityZone.createButton({click_function="updatePower",
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,180,0},
            label="+1",
            tooltip="Click to update villain's power!",
            font_size=350,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
    else
        local citycards = Global.Call('get_decks_and_cards_from_zone',fortifiedCityZoneGUID)
        if citycards[1] then
            for _,o in pairs(citycards) do
                if o.hasTag("Villain") then
                    Global.Call('get_decks_and_cards_from_zone',bszoneguid)[1].takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                        flip=true})
                    broadcastToAll("Scheme Twist: Bystander KO'd!")
                    break
                end
            end
        end
    end
    return twistsresolved
end
