function onLoad()
    local guids1 = {
        "pushvillainsguid"
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

function playTwoFamily(params)
    local obj = params.obj
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2,vildeckguid = obj.guid})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    broadcastToAll("Scheme Twist: Choose a villain deck to draw two cards from.")
    local decks = {}
    for i,o in pairs(allTopBoardGUIDS) do
        local deck = Global.Call('get_decks_and_cards_from_zone',o)
        if deck[1] then
            for _,b in pairs(getObjectFromGUID(o).getButtons()) do
                if b.click_function == "click_draw_villain_call" then
                    table.insert(decks,getObjectFromGUID(o))
                    break
                end
            end
        end
    end
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
        hand = decks,
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