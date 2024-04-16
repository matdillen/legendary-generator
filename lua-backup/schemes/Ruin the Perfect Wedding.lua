function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "mmZoneGUID",
        "setupGUID",
        "heroPileGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs",
        "pos_discard",
        "city_zones_guids",
        "allTopBoardGUIDS"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "discardguids"
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

function orderAdam(obj)
    for _,o in pairs(obj.getObjects()) do
        local pos = obj.getPosition()
        for _,k in pairs(o.tags) do
            if k:find("Cost:") then
                pos.y = pos.y + 12 - k:match("%d+")
                break
            end
        end
        if obj.getQuantity() > 1 then
            obj.takeObject({position=pos,
                guid = o.guid})
            if obj.remainder then
                obj = obj.remainder
            end
        else
            obj.setPositionSmooth(pos)
        end
    end
end

function setupSpecial(params)
    local tobewed = {}
    for s in string.gmatch(params.setupParts[9],"[^|]+") do
        table.insert(tobewed, string.lower(s))
    end
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 1,8 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
    log("Extra heroes to be wed in separate piles.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = tobewed[1],
        pileGUID = heroPileGUID,
        destGUID = topBoardGUIDs[1],
        callbackf = "orderAdam",
        fsourceguid = self.guid})
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = tobewed[2],
        pileGUID = heroPileGUID,
        destGUID = topBoardGUIDs[8],
        callbackf = "orderAdam",
        fsourceguid = self.guid})
end

function resolveTheRuinedWedding(params)
    local obj = params.obj
    
    obj.takeObject({position = dest})
    if twistsresolved == 3 then
        for i=1,2 do
            aislehero.takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                smooth = true})
        end
    else
        local citycontent = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[-twistsresolved+10])
        if citycontent[1] then
            for _,o in pairs(citycontent) do
                if o.hasTag("Villain") or o.hasTag("Mastermind") then
                    for i=1,2 do
                        aislehero.takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                            smooth = true})
                    end
                    break
                end
            end
        end
    end
    local citycontent = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[2])
    if citycontent[1] then
        for _,o in pairs(citycontent) do
            if o.hasTag("Villain") or o.hasTag("Mastermind") then
                for i=1,2 do
                    altarhero.takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                        smooth = true})
                end
                break
            end
        end
    end
    if twistsresolved < 7 then
        aislehero.setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[4+twistsresolved]).getPosition())
    else
        altarhero.setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[12]).getPosition())
        aislehero.setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[4+twistsresolved]).getPosition())
    end
end

function resolveTwist(params)
    twistsresolved = params.twistsresolved 
    local schemeParts = table.clone(getObjectFromGUID(setupGUID).Call('returnVar',"setupParts"))

    dest = getObjectFromGUID(discardguids[Turns.turn_color]).getPosition()
    dest.y = dest.y + 3
    if twistsresolved == 1 then
        local tobewed = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[8])
        tobewed[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[7]).getPosition())
        tobewed[1].takeObject({position = dest})
        broadcastToAll("Scheme Twist: Hero " .. schemeParts[9]:gsub(".*%|","") .. " moved to the altar!")
    elseif twistsresolved == 2 then
        local tobewed = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])
        tobewed[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
        tobewed[1].takeObject({position = dest})
        broadcastToAll("Scheme Twist: Hero " .. schemeParts[9]:gsub("%|.*","") .. " moved to the door!")
    elseif twistsresolved < 8 then
        aislehero = Global.Call('get_decks_and_cards_from_zone',allTopBoardGUIDS[3+twistsresolved])[1]
        altarhero = Global.Call('get_decks_and_cards_from_zone',allTopBoardGUIDS[11])[1]
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = {aislehero,altarhero},
            pos = "Stay",
            label = "Gain",
            tooltip = "Gain a card from this wedding stack.",
            trigger_function = 'resolveTheRuinedWedding',
            args = "self",
            buttonheight = 8,
            fsourceguid = self.guid})
        broadcastToAll("Scheme Twist: Gain the top card of one of the hero stacks. Two cards from each hero stack are KO'd if an enemy occupies the city space below it. Then the left stack is moved one space to the right.")
    elseif twistsresolved < 12 then
        aislehero = Global.Call('get_decks_and_cards_from_zone',allTopBoardGUIDS[11])[1]
        altarhero = Global.Call('get_decks_and_cards_from_zone',allTopBoardGUIDS[12])[1]
        if not aislehero or not altarhero or aislehero.tag == "Card" or altarhero.tag == "Card" or aislehero.getQuantity() == 2 or altarhero.getQuantity() == 2 then
            broadcastToAll("Wedding hero completely KO'd after this twist. Evil wins!")
            return nil
        else
            for i=1,2 do
                altarhero.takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                    smooth = true})
                aislehero.takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                    smooth = true})
            end
        end
        broadcastToAll("Scheme Twist: Two cards from each hero stack KO'd.")
    end
    return twistsresolved
end