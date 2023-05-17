function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness
    local city = params.city

    local foomcount = 0
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,k in pairs(citycontent) do
                if k.hasTag("Group:Monsters Unleashed") then
                    foomcount = foomcount + 1
                    break
                end
            end
        end
    end
    local escapedcards = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
    if escapedcards[1] and escapedcards[1].tag == "Deck" then
        for _,o in pairs(escapedcards[1].getObjects()) do
            for _,k in pairs(o.tags) do
                if k == "Group:Monsters Unleashed" then
                    foomcount = foomcount + 1
                    break
                end
            end
        end
    elseif escapedcards[1] and escapedcards[1].tag == "Card" then
        if escapedcards[1].hasTag("Group:Monsters Unleashed") then
            foomcount = foomcount + 1
        end
    end
    getObjects(pushvillainsguid).Call('demolish',{n = foomcount+1,ko = epicness})
    broadcastToAll("Master Strike: Each player is demolished " .. foomcount+1 .. " times!")
    if epicness then
        broadcastToAll("KO all heroes demolished this way!")
    end
    return strikesresolved
end
