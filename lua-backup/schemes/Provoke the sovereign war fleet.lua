function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function resolveTwist(params)
    local cards = params.cards
    
    cards[1].setName("Sovereign Omnicraft")
    cards[1].setTags({"VP1","Villain","Power:2"})
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
    pos.y = pos.y + 2
    local any = false
    for _,o in pairs(Player.getPlayers) do
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
                content.setPosition(pos)
                any = true
            else
                for _,c in pairs(toshuffle) do
                    content.takeObject({position = pos,
                        flip = true,
                        guid = c})
                end
                any = true
            end
        elseif content and content.getName() == "Sovereign Omnicraft" then
            content.flip()
            content.setPosition(pos)
            any = true
        end
    end
    if any == true then
        Wait.time(function()
            local deck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
            deck.randomize()
            end,0.3)
    end
    Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('playVillains') end,0.5)
    return nil
end