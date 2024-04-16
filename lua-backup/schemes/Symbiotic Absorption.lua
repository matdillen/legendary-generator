function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "setupGUID"
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

function table.clone(params)
    if params.key then
        local new = {}
        for i,o in pairs(params.org) do
            new[i] = o
        end
        return new
    else
        return {table.unpack(params.org)}
    end
end

function setupSpecial(params)
    log("Add extra drained mastermind.")
    local mmZone = getObjectFromGUID(mmZoneGUID)
    mmZone.Call('lockTopZone',topBoardGUIDs[1])
    getObjectFromGUID(setupGUID).Call('findInPile',{deckName = params.setupParts[9],
        pileGUID = mmPileGUID,
        destGUID = topBoardGUIDs[1],
        callbackf = "mmshuffle",
        fsourceguid = self.guid})
end

function mmshuffle(obj)
    local mm = obj
    local mmcardnumber = getObjectFromGUID(mmZoneGUID).Call('mmGetCards',mm.getName())
    if mmcardnumber == 4 then
        mm.randomize()
        log("Mastermind tactics shuffled")
    end
    local mmSepShuffle = function(obj)
        mm.flip()
        mm.randomize()
        log("Mastermind tactics shuffled")
    end
    if mmcardnumber == 5 then
        mm.takeObject({
            position={x=mm.getPosition().x,
                y=mm.getPosition().y+2,
                z=mm.getPosition().z},
                flip = false,
                callback_function = mmSepShuffle
            })
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    local city = params.city
    
    local schemeParts = table.clone(getObjectFromGUID(setupGUID).Call('returnSetupParts'))

    local mmZone=getObjectFromGUID(mmZoneGUID)
    if twistsresolved < 5 then
        local mmcards = Global.Call('get_decks_and_cards_from_zone',mmZoneGUID)
        local mmcount = 0
        if mmcards[1] then
            for _,o in pairs(mmcards) do
                if o.is_face_down == true then
                    mmcount = math.abs(o.getQuantity())
                end
            end
        else
            broadcastToAll("No mastermind found?")
            return nil
        end
        local mmshuffle = function(obj)
            local mmcards = Global.Call('get_decks_and_cards_from_zone',mmZoneGUID)
            local pos = getObjectFromGUID(mmZoneGUID).getPosition()
            pos.y = pos.y + 3
            if mmcards[1] then
                for _,o in pairs(mmcards) do
                    if o.is_face_down == false then
                        o.setPositionSmooth(pos)
                        break
                    end
                end
            end
            local mmSepShuffle = function()
                local mmcards = Global.Call('get_decks_and_cards_from_zone',mmZoneGUID)
                mmcards[1].randomize()
                log("Mastermind tactics shuffled")
            end
            Wait.time(mmSepShuffle,1)
        end
        local tacticMoved = function()
            local mmcards = Global.Call('get_decks_and_cards_from_zone',mmZoneGUID)
            if mmcards[1] then
                for _,o in pairs(mmcards) do
                    if o.is_face_down == true then
                        if mmcount == math.abs(o.getQuantity())-1 then
                            return true
                        end
                    end
                end
                return false
            else
                return false
            end
        end
        local drainedmm = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])
        if drainedmm[1] then
            for _,o in pairs(drainedmm) do
                if o.is_face_down == true then
                    if o.getQuantity() > 1 then
                        o.takeObject({position = mmZone.getPosition()})
                    else
                        o.setPositionSmooth(mmZone.getPosition())
                    end
                    Wait.condition(mmshuffle,tacticMoved)
                end
            end
        else
            broadcastToAll("Drained mastermind not found.")
            return nil
        end
        Wait.time(function() 
            getObjectFromGUID(mmZoneGUID).Call('click_update_tactics',getObjectFromGUID(mmZoneGUID))
            end,1.5)
    elseif twistsresolved % 2 == 0 and twistsresolved < 11 then
        broadcastToAll("Scheme Twist: This twist copies the master strike effect of the drained mastermind!")
        local result = getObjectFromGUID(pushvillainsguid).Call('resolveStrike2',{mmname = schemeParts[9],
            epicness = false,
            city = city,
            cards = cards,
            mmoverride = true})
        if result then
            return twistsresolved
        else
            return nil
        end
    elseif twistsresolved == 11 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end
