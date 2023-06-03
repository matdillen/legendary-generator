function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playerBoards",
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

function shiftPsychoticBreak(color)
    local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',color)
    currentPsychoticBreak.setPositionSmooth(getObjectFromGUID(playerBoards[nextcolor]).positionToWorld({-1.5,4,4}))
    promptPsychoticBreakChoice(nextcolor)
end

function keepPsychoticBreak(obj)
    obj.clearButtons()
    local color = nil
    for _,o in pairs(Player.getPlayers()) do
        local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[o.color])
        if playcontent[1] then
            for _,k in pairs(playcontent) do
                if k.guid == obj.guid then
                    color = o.color
                    break
                end
            end
            if color then
                break
            end
        end
    end
    local pos = obj.getPosition()
    if color == "White" then
        pos.z = pos.z + 14
    elseif color == "Blue" then
        pos.z = pos.z - 14
    else
        pos.x = pos.x + 14
    end
    obj.setPositionSmooth(pos)
    obj.locked = true
    local hand = Player[color].getHandObjects()
    for _,h in pairs(hand) do
        h.clearButtons()
    end
end

function promptPsychoticBreakChoice(color)
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = color,
        trigger_function = 'shiftPsychoticBreak',
        args = color,
        fsourceguid = self.guid})
        
    currentPsychoticBreak.createButton({click_function="keepPsychoticBreak",
        function_owner=self,
        position={0,22,0},
        label="Keep",
        tooltip="Keep this psychotic break.",
        font_size=250,
        font_color="Black",
        color={1,1,1},
        width=750,height=450})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    cards[1].setName("Psychotic Break")
    cards[1].setDescription("ARTIFACT: Not really, but this ensures it sticks during cleanup.")
    cards[1].setPositionSmooth(getObjectFromGUID(playerBoards[Turns.turn_color]).positionToWorld({-1.5,4,4}))
    currentPsychoticBreak = cards[1]
    broadcastToAll("Scheme Twist: Discard a card and pass the break to the next player, or keep it!")

    promptPsychoticBreakChoice(Turns.turn_color)
    function onPlayerTurn(player)
        local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[player.color])
        if playcontent[1] then
            local breakcount = 0
            for _,o in pairs(playcontent) do
                if o.tag == "Deck" then
                    for _,k in pairs(o.getObjects()) do
                        if k.name == "Psychotic Break" then
                            breakcount = breakcount + 1
                        end
                    end
                elseif o.tag == "Card" then
                    if o.getName() == "Psychotic Break" then
                        breakcount = breakcount + 1
                    end
                end
            end
            if breakcount > 0 then
                local hand = player.getHandObjects()
                local pos = getObjectFromGUID(playerBoards[player.color]).positionToWorld({-3.5,4,4})
                if #hand >= breakcount*2 then
                    for i=1,breakcount*2 do
                        local card = table.remove(hand,math.random(#hand))
                        card.setPosition(pos)
                        pos.x = pos.x + 1
                        pos.y = pos.y + 1
                    end
                else
                    for i=1,#hand do
                        local card = table.remove(hand,math.random(#hand))
                        card.setPosition(pos)
                        pos.x = pos.x + 1
                        pos.y = pos.y + 1
                    end
                end
                broadcastToColor("Psychotic Break! Play and activate cards from hand in random order, from left to right!",player.color,player.color)
            end
        end
    end
    return nil
end