function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "vpileguids",
        "resourceguids"
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

function fightEffect(params)
    if params.obj.getName() == "Sovereign Omnicraft" then
        getObjectFromGUID(resourceguids[params.color]).Call('addValue',1)
        broadcastToColor("You defeated a Sovereign Omnicraft and got 1 Recruit.",params.color,params.color)
    end
end

function removeSOTags(object)
    object.setName("Scheme Twist")
    object.setTags({})
end

function resolveTwist(params)
    local cards = params.cards
    
    cards[1].setName("Sovereign Omnicraft")
    cards[1].setTags({"VP1","Villain","Power:2"})
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
    local villaindeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    local villaindeckcount = 0
    if villaindeck then
        villaindeckcount = math.abs(villaindeck.getQuantity())
    end
    local toadd = 0
    pos.y = pos.y + 2
    local any = false
    for _,o in pairs(Player.getPlayers()) do
        local content = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])[1]
        if content and content.tag == "Deck" then
            local toshuffle = {}
            for _,c in pairs(content.getObjects()) do
                if c.name == "Sovereign Omnicraft" then
                    table.insert(toshuffle,c.guid)
                end
            end
            if #toshuffle == #content then
                content.flip()
                removeSOTags(content)
                content.setPosition(pos)
                any = true
                toadd = #toshuffle
            else
                for _,c in pairs(toshuffle) do
                    content.takeObject({position = pos,
                        flip = true,
                        guid = c,
                        callback_function = removeSOTags})
                        pos.y = pos.y + 1
                    toadd = toadd + 1
                end
                any = true
            end
        elseif content and content.getName() == "Sovereign Omnicraft" then
            content.flip()
            removeSOTags(content)
            content.setPosition(pos)
            any = true
            toadd = 1
        end
    end
    villaindeckcount = villaindeckcount + toadd
    if any == true then
        Wait.condition(
            function()
                local deck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
                if deck.tag == "Deck" then
                    deck.randomize()
                end
                Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('playVillains') end,0.1)
            end,
            function()
                local deck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
                if deck and math.abs(deck.getQuantity()) == villaindeckcount then
                    return true
                else
                    return false
                end
            end)
    end
    return nil
end