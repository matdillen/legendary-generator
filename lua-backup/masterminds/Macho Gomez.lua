function onLoad()
    mmname = "Macho Gomez"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playguids",
        "playerBoards",
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

function updateMMMacho()
    local color = Turns.turn_color
    local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[color])
    local savior = 0
    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
        for _,k in pairs(vpilecontent[1].getObjects()) do
            for _,l in pairs(k.tags) do
                if l == "Group:Deadpool's \"Friends\"" then
                    savior = savior + 1
                    break
                end
            end
        end
    elseif vpilecontent[1] then
        if vpilecontent[1].hasTag("Group:Deadpool's \"Friends\"") then
            savior = 1
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = savior,
        label = "+" .. savior,
        tooltip = "Macho Gomez gets +1 in revenge for each Deadpool's \"Friends\" villain in your victory pile.",
        f = 'updateMMMacho',
        f_owner = self})
end

function setupMM()
    updateMMMacho()
    function onObjectEnterZone(zone,object)
        if object.hasTag("Villain") then
            Wait.time(updateMMMacho,0.1)
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.hasTag("Villain") then
            Wait.time(updateMMMacho,0.1)
        end
    end
    function onPlayerTurn(player,previous_player)
        updateMMMacho()
    end
end

function resolveStrike(params)
    local cards = params.cards

    if cards[1] then
        cards[1].setName("Bounty on your head")
        cards[1].setDescription("ARTIFACT: This is a bounty on your head. Macho will wound" ..
        " you with his master strikes for each bounty you have. Pay 1 recruit during your turn to pass this bounty to the player on your left.")
        local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[Turns.turn_color])
        local xshift = 0
        if playcontent[1] then
            for _,o in pairs(playcontent) do
                if o.getName() == "Bounty on your head" then
                    xshift = xshift + 0.5
                end
            end
        end
        cards[1].setPositionSmooth(getObjectFromGUID(playerBoards[Turns.turn_color]).positionToWorld({-1.5+xshift,4,4}))
    end
    broadcastToAll("Master Strike: Each player gains a Wound for each Bounty on them.")
    for _,o in pairs(Player.getPlayers()) do
        local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[o.color])
        local bounties = 0
        if o.color == Turns.turn_color then
            bounties = 1
        end
        if playcontent[1] then
            for _,o in pairs(playcontent) do
                if o.tag == "Card" and o.getName() == "Bounty on your head" then
                    bounties = bounties + 1
                elseif o.tag == "Deck" then
                    for _,k in pairs(o.getObjects()) do
                        if k.name == "Bounty on your head" then
                            bounties = bounties + 1
                        end
                    end
                end
            end
        end
        if bounties > 0 then
            for i = 1,bounties do
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
            end
        end
    end
    return nil
end
