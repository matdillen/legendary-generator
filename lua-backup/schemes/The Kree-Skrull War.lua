function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    if twistsresolved < 8 then
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if hasTag2(obj,"Group:",7) and (hasTag2(obj,"Group:",7) == "Kree Starforce" or hasTag2(obj,"Group:",7) == "Skrulls") then
                        getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = citycontent,
                            targetZone = getObjectFromGUID(escape_zone_guid),
                            enterscity = 0,
                            schemeParts = {self.getName()}})
                        break
                    end
                end
            end
        end
        local kreeskrull = function()
            local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
            local skree = 0
            if escaped[1] and escaped[1].tag == "Deck" then
                for _,o in pairs(escaped[1].getObjects()) do
                    for _,tag in pairs(o.tags) do
                        if tag == "Group:Kree Starforce" then
                            skree = skree - 1
                            break
                        elseif tag == "Group:Skrulls" then
                            skree = skree + 1
                            break
                        end
                    end
                end
            elseif escaped[1] and hasTag2(escaped[1],"Group:",7) then
                if hasTag2(escaped[1],"Group:",7) == "Kree Starforce" then
                    skree = -1
                elseif hasTag2(escaped[1],"Group:",7) == "Skrulls" then
                    skree = 1
                end
            end
            if skree < 0 then
                cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
                broadcastToAll("Scheme Twist: All Kree and Skrull villains escape! Kree Conquest!")
            elseif skree > 0 then
                cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[4]).getPosition())
                broadcastToAll("Scheme Twist: All Kree and Skrull villains escape! Skrull Conquest!")
            else
                broadcastToAll("Scheme Twist: All Kree and Skrull villains escape! Stalemate, no conquest!")
                koCard(cards[1])
            end
        end
        Wait.time(kreeskrull,2)
    elseif twistsresolved == 8 then
        local skree = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[2])
        local skrull = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[4])
        local score = math.abs(skrull[1].getQuantity()) - math.abs(skree[1].getQuantity())
        if score < 0 then
            cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
            broadcastToAll("Scheme Twist: Kree Conquest!")
        elseif score > 0 then
            cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[4]).getPosition())
            broadcastToAll("Scheme Twist: Skrull Conquest!")
        else
            broadcastToAll("Scheme Twist: Stalemate, no conquest!")
            getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
        end
    end
    return nil
end
