function onLoad()
    mmname = "Fin Fang Foom"
    
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playguids"
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

function updateMMFinFang()
    local hccolors = {
        ["Red"] = 0,
        ["Yellow"] = 0,
        ["Green"] = 0,
        ["Silver"] = 0,
        ["Blue"] = 0
    }
    local playedcards = Global.Call('get_decks_and_cards_from_zone',playguids[Turns.turn_color])
    if playedcards[1] then
        for _,o in pairs(playedcards) do
            local tags = o.getTags()
            if tags then
                for _,tag in pairs(tags) do
                    if tag:find("HC:") then
                        hccolors[tag:gsub("HC:","")] = 2
                    end
                    if tag:find("HC1:") then
                        hccolors[tag:gsub("HC1:","")] = 2
                    end
                    if tag:find("HC2:") then
                        hccolors[tag:gsub("HC2:","")] = 2
                    end
                end
            end
        end
    end
    local hand = Player[Turns.turn_color].getHandObjects()
    if hand[1] then
        for _,o in pairs(hand) do
            local tags = o.getTags()
            if tags then
                for _,tag in pairs(tags) do
                    if tag:find("HC:") then
                        hccolors[tag:gsub("HC:","")] = 2
                    end
                    if tag:find("HC1:") then
                        hccolors[tag:gsub("HC1:","")] = 2
                    end
                    if tag:find("HC2:") then
                        hccolors[tag:gsub("HC2:","")] = 2
                    end
                end
            end
        end
    end
    local boost = 0
    for _,o in pairs(hccolors) do
        boost = boost + o
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = boost,
        label = "-" .. boost,
        tooltip = "Fin Fang Foom gets -2 for each different Hero Class among heroes you have.",
        f = 'updateMMFinFang',
        f_owner = self})
end

function setupMM()
    updateMMFinFang()
    function onObjectEnterZone(zone,object)
        updateMMFinFang()
    end
    function onObjectLeaveZone(zone,object)
        updateMMFinFang()
    end
    function onPlayerTurn(player,previous_player)
        updateMMFinFang()
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
