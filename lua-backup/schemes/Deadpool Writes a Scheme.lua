function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playerBoards"
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
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city
    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    if twistsresolved == 1 then
        for i,o in pairs(playerBoards) do
            if Player[i].seated then
                getObjectFromGUID(o).Call('click_draw_card')
            end
        end
        broadcastToAll("Scheme Twist: Everybody draw 1 card. Wait, are these supposed to be bad?")
    elseif twistsresolved == 2 then
        broadcastToAll("Scheme Twist: Anyone without a Deadpool in hand is doing it wrong -- discard 2 cards.")
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local deadpoolfound = false
            for _,obj in pairs(hand) do
                if obj.getName():find("Deadpool") or obj.hasTag("Team:Deadpool") or obj.getName():find("Venompool") then
                    deadpoolfound = true
                    break
                end
            end
            if not deadpoolfound and hand[1] then 
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,hand = hand, n = 2})
            end
        end
    elseif twistsresolved == 3 then  
        getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=3})
        broadcastToAll("Scheme Twist: Play 3 cards from the Villain Deck. That sounds pretty bad, right?")
    elseif twistsresolved == 4 then
        for _,o in pairs(city) do
            local citycards = Global.Call('get_decks_and_cards_from_zone',o)
            if citycards[1] then
                for _,i in pairs(citycards) do
                    if i.hasTag("Villain") then
                        for i = 1,4 do
                            getObjectFromGUID(pushvillainsguid).Call('addBystanders',o)
                        end
                        break
                    end
                end
            end
        end
        broadcastToAll("Scheme Twist: Each Villain captures 4 Bystanders. Hey, I'm not a balance expert.")
    elseif twistsresolved == 5 then
        for i = 1,4 do
            getObjectFromGUID(pushvillainsguid).Call('dealWounds')
        end
        broadcastToAll("Scheme Twist: Each player gains 5 Wounds. Is that a good number?")
    elseif twistsresolved == 6 then
        for i = 1,6 do
            broadcastToAll("Deadpool wins 6 times! Wow, I'm way better at this game than you.",{1,0,0})
        end
    end
    return nil    
end