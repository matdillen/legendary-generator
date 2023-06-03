function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
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
    
    local guids3 = {
        "vpileguids"
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

function nonTwist(params)
    local obj = params.obj
    
    if obj.hasTag("Villain") and not obj.getDescription():find("FATEFUL RESURRECTION") then
        if obj.getDescription() == "" then
            obj.setDescription("FATEFUL RESURRECTION: Reveal the top card of the Villain Deck. If it's a Scheme Twist or Master Strike, this card goes back to where it was when fought.")
        else
            obj.setDescription(obj.getDescription() .. "\r\nFATEFUL RESURRECTION: Reveal the top card of the Villain Deck. If it's a Scheme Twist or Master Strike, this card goes back to where it was when fought.")
        end
    end
    return 1
end

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function thirstyVillain(params)
    local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
    params.obj.setPositionSmooth(pos)
    Wait.time(click_push_villain_into_city,1)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    broadcastToAll("Scheme Twist: A villain from your victory pile enters the sewers. Twist card is put on bottom of the villain deck.")
    local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[Turns.turn_color])[1]
    local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
    if vpile and vpile.tag == "Deck" then
        local villainsfound = {}
        for _,o in pairs(vpile.getObjects()) do
            for _,tag in pairs(o.tags) do
                if tag == "Villain" then
                    table.insert(villainsfound,o.guid)
                    break
                end
            end
        end
        if #villainsfound > 1 then
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = Turns.turn_color,
                pile = vpile,
                guids = villainsfound,
                resolve_function = 'thirstyVillain',
                tooltip = "Push this villain card into the city.",
                args = "self",
                label = "Push",
                fsourceguid = self.guid})
        elseif villainsfound[1] then
            vpile.takeObject({position = pos,
                smooth = true,
                guid = villainsfound[1],
                callback_function = click_push_villain_into_city})
        end
    elseif vpile and vpile.hasTag("Villain") then
        vpile.setPositionSmooth(pos)
        Wait.time(click_push_villain_into_city,1)
    end
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
    if vildeck[1] then
        local pos = vildeck[1].getPosition()
        pos.y = pos.y + 3
        vildeck[1].setPositionSmooth(pos)
    end
    cards[1].flip()
    cards[1].setPositionSmooth(getObjectFromGUID(villainDeckZoneGUID).getPosition())
    return nil
end