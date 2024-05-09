function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "bystandersPileGUID",
        "kopile_guid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS",
        "topBoardGUIDs",
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function setupSpecial(params)
    local sewers = getObjectFromGUID(topBoardGUIDs[7])
    getObjectFromGUID(bystandersPileGUID).setPositionSmooth(sewers.getPosition())
    log("[scheme : Ferry Disaster] Bystander stack moved above the Sewers.")
    removeRescueButton(getObjectFromGUID(pushvillainsguid))
    addRescueButton(sewers)
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 3,7 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
end

function addRescueButton(zone)
    zone.createButton({
        click_function="click_rescue_bystander", function_owner=getObjectFromGUID(pushvillainsguid),
        position={0,0,0}, label="Rescue Bystander", color={0.6,0.4,0.8,1}, width=2000, height=1000,
        tooltip = "Rescue a bystander",
        font_size = 250
    })
end

function removeRescueButton(zone)
    Global.Call('removeButton',{obj = zone,click_f = "click_rescue_bystander"})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    if twistsresolved == 1 or twistsresolved == 5 then
        ferryzones = {table.unpack(allTopBoardGUIDS,7,11)}
    end
    if twistsresolved < 5 then
        local previous = getObjectFromGUID(table.remove(ferryzones))
        local next = getObjectFromGUID(ferryzones[#ferryzones])
        local bspile = getObjectFromGUID(bystandersPileGUID)
        bspile.setPositionSmooth(next.getPosition())
        removeRescueButton(previous)
        addRescueButton(next)
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
        local previous = getObjectFromGUID(table.remove(ferryzones,1))
        local next = getObjectFromGUID(ferryzones[1])
        local bspile = getObjectFromGUID(bystandersPileGUID)
        bspile.setPositionSmooth(next.getPosition())
        removeRescueButton(previous)
        addRescueButton(next)
        local citycards = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[#ferryzones+2])
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