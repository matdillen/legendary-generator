function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "mmZoneGUID"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function setupSpecial(params)
    local mmZone = getObjectFromGUID(mmZoneGUID)
    mmZone.Call('lockTopZone',topBoardGUIDs[2])
    mmZone.Call('lockTopZone',topBoardGUIDs[4])
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    if twistsresolved < 8 then
        local escapees = {}
        local escapeesc = 0
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if hasTag2(obj,"Group:",7) and (hasTag2(obj,"Group:",7) == "Kree Starforce" or hasTag2(obj,"Group:",7) == "Skrulls") then
                        escapees[obj.guid] = true
                        escapeesc = escapeesc + 1
                        getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = table.clone(citycontent),
                            currentZone = getObjectFromGUID(o),
                            targetZone = getObjectFromGUID(escape_zone_guid),
                            enterscity = 0})
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
        local kreeskrullEscaped = function()
            local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
            local newescapees = 0
            if escaped[1] and escaped[1].tag == "Deck" then
                for _,o in pairs(escaped[1].getObjects()) do
                    if escapees[o.guid] then
                        newescapees = newescapees + 1
                    end
                end
            elseif escaped[1] and hasTag2(escaped[1],"Group:",7) then
                if escapees[escaped[1].guid] then
                    newescapees = newescapees + 1
                end
            end
            if newescapees == escapeesc then
                return true
            else
                return false
            end
        end
        Wait.condition(kreeskrull,kreeskrullEscaped)
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
