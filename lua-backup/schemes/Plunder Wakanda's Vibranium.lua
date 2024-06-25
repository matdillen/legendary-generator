function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Vibranium in escape pile: __/4.",
                ["zoneguid"] = escape_zone_guid,
                ["zoneguid2"] = villainDeckZoneGUID,
                ["tooltip2"] = "Villain deck count: __."}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Vibranium"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Vibranium") then
            counter = counter + 1
        end
        return counter
    end
end

function setupCounter2()
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck then
        return math.abs(vildeck.getQuantity())
    else
        return 0
    end
end

function resolveTwist(params) 
    local cards = params.cards
    local city = params.city
    
    cards[1].setName("Vibranium")
    cards[1].setTags({"Villainous Weapon","VP3","Vibranium"})
    
    local pos =getObjectFromGUID(escape_zone_guid).getPosition()
    for _,o in pairs(city) do
        local content = Global.Call('get_decks_and_cards_from_zone',o)
        if content[1] then
            for _,c in pairs(content) do
                if c.getName() == "Vibranium" then
                    c.setPosition(pos)
                end
            end
        end
    end
    broadcastToAll("incomplete twist scripting")
    return nil
end