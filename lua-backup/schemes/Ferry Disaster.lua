function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "bystandersPileGUID",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS",
        "city_zones_guids"
        }
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    if twistsresolved == 1 or twistsresolved == 5 then
        ferryzones = {table.unpack(allTopBoardGUIDS,7,11)}
    end
    if twistsresolved < 5 then
        table.remove(ferryzones)
        local bspile = getObjectFromGUID(bystandersPileGUID)
        bspile.setPositionSmooth(getObjectFromGUID(ferryzones[#ferryzones]).getPosition())
        local citycards = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[twistsresolved+1])
        if citycards[1] then
            for _,o in pairs(citycards) do
                if o.hasTag("Villain") then
                    bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                        flip=true,smooth=true})
                    bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                        flip=true,smooth=true})
                    broadcastToAll("Scheme Twist: Two bystanders fell from the ferry and were KO'd!")
                    break
                end
            end
        end
    elseif twistsresolved < 9 then
        table.remove(ferryzones,1)
        local bspile = getObjectFromGUID(bystandersPileGUID)
        bspile.setPositionSmooth(getObjectFromGUID(ferryzones[1]).getPosition())
        local citycards = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[#ferryzones])
        if citycards[1] then
            for _,o in pairs(citycards) do
                if o.hasTag("Villain") then
                    bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                        flip=true,smooth=true})
                    bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                        flip=true,smooth=true})
                    broadcastToAll("Scheme Twist: Two bystanders fell from the ferry and were KO'd!")
                    break
                end
            end
        end
    elseif twistsresolved == 9 then
        local bspile = getObjectFromGUID(bystandersPileGUID)
        for i=1,math.floor(0.5+bspile.getQuantity()/2) do
            bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                flip=true,smooth=true})
        end
        broadcastToAll("Scheme Twist: The ferry sank. Half of all the bystanders drowned!")
    end
    return twistsresolved
end