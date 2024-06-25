function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
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

function setupCounter(init)
    if init then
        local playercounter = 3*#Player.getPlayers()
        return {["zoneguid"] = kopile_guid,
                ["tooltip"] = "KO'd nongrey heroes: __/" .. playercounter .. "."}
    else 
        local escaped = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        if escaped[1] then
            local counter = 0
            for _,o in pairs(escaped) do
                if o.tag == "Deck" then
                    local escapees = Global.Call('hasTagD',{deck = o,tag = "HC:",find=true})
                    if escapees then
                        counter = counter + #escapees
                    end
                elseif hasTag2(o,"HC:") then
                    counter = counter + 1
                end
            end
            return counter
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Green")
    for i,o in pairs(players) do
        local feastOn = function()
            local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
            if deck[1] and deck[1].tag == "Deck" then
                local pos = getObjectFromGUID(kopile_guid).getPosition()
                deck[1].takeObject({position = pos,
                    flip=true})
                return true
            elseif deck[1] then
                deck[1].flip()
                getObjectFromGUID(pushvillainsguid).Call('koCard',deck[1])
                return true
            else
                return false
            end
        end
        local feasted = feastOn()
        broadcastToAll("Scheme Twist: Player " .. o.color .. " had no Green hero and KOs the top card of their deck")
        if feasted == false then
            broadcastToAll("Shuffling " .. o.color .. " player's discard pile into their deck first...")
            local discard = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
            if discard[1] then
                getObjectFromGUID(playerBoards[o.color]).Call('click_refillDeck')
                Wait.time(feastOn,2)
            end
        end
    end
    return twistsresolved
end