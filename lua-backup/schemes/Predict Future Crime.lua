function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck then
        local vildeckcount = vildeck.getQuantity()
        local villainsfound = 0
        if vildeck.tag == "Deck" and vildeckcount > 3 then
            local vildeckcontent = vildeck.getObjects()
            local vilcheck = {}
            for j = 1,3 do
                broadcastToAll("Card revealed from villain deck: " .. vildeckcontent[j].name)
                for _,k in pairs(vildeckcontent[j].tags) do
                    if k == "Villain" then
                        table.insert(vilcheck,5)
                        villainsfound = villainsfound + 1
                        break
                    end
                end
                if not vilcheck[j] then
                    table.insert(vilcheck,2)
                end
            end
            if villainsfound > 0 and villainsfound < 3 then
                local playCriminals = function(obj)
                    local cardsLanded = function()
                        local test = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1].getQuantity()
                        if test == vildeckcount then
                            return true
                        else
                            return false
                        end
                    end
                    local playCards = function()
                        getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=villainsfound})
                    end
                    Wait.condition(playCards,cardsLanded)
                end
                local callback_f = nil
                for j = 1,3 do
                    if j == 3 then
                        callback_f = playCriminals
                    else
                        callback_f = nil
                    end 
                    local vildeckpos = vildeck.getPosition()
                    --add another j to prevent taken objects from spawning into a container
                    --as this prevents the callback from triggering
                    vildeckpos.y = vildeckpos.y + vilcheck[j] + j
                    vildeck.takeObject({position=vildeckpos,
                        callback_function = callback_f})
                end
            elseif villainsfound == 3 then
                getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=3})
            end
        --still script for villain decks of size 3 and 2
        elseif vildeck.tag == "Card" and vildeck.hasTag("Villain") then
            getObjectFromGUID(pushvillainsguid).Call('playVillain',1)
        end
    else
        broadcastToAll("Villain deck is empty?")
    end
    return twistsresolved
end
