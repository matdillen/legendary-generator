function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function playTwoFamily(params)
    getObjectFromGUID(setupGUID).Call('click_draw_villain_call',params.obj)
    getObjectFromGUID(setupGUID).Call('click_draw_villain_call',params.obj)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    
    broadcastToAll("Scheme Twist: Choose a villain deck to draw two cards from.")
    local decks = {}
    for i,o in pairs(allTopBoardGUIDS) do
        if i > 6 and i < 12 then
            local deck = Global.Call('get_decks_and_cards_from_zone',o)
            if deck[1] then
                table.insert(decks,getObjectFromGUID(o))
            end
        end
    end
    
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
        hand = table.clone(decks),
        pos = "Stay",
        label = "Play",
        tooltip = "Play two cards from this villain deck.",
        trigger_function = 'playTwoFamily',
        args = "self",
        buttoncolor = "Red",
        isZone = true,
        fsourceguid = self.guid})
    return twistsresolved
end