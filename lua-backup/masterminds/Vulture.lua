function onLoad()
    mmname = "Vulture"
    
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "woundsDeckGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function updateMMVulture()
    local strikes = getObjectFromGUID(pushvillainsguid).Call('returnVar','strikesresolved')
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = strikes,
        label = "+" .. strikes,
        tooltip = "Vulture is a striker and gets +1 for each Master Strike that has been played.",
        f = 'updateMMVulture',
        id = "striker",
        f_owner = self})
end

function setupMM()
    updateMMVulture()
    function onObjectEnterZone(zone,object)
        if object.getName() == "Masterstrike" then
            updateMMVulture()
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    local kodwounds = {}
    local vultureWounds = function()
        local totake = 0
        if epicness and kodwounds[1] then
            totake = math.min(#kodwounds,5)
        end
        for i,o in pairs(hqguids) do
            local cityzone = getObjectFromGUID(o)
            local pos = cityzone.getPosition()
            pos.z = pos.z - 2
            pos.y = pos.y + 3
            if totake > 0 then
                local guid = table.remove(kodwounds,math.random(#kodwounds))
                local kopile = Global.Call('get_decks_and_cards_from_zone',kopile_guid)[1]
                kopile.takeObject({position = pos,
                    guid = guid, smooth = true})
                if kopile.remainder and kopile.remainder.hasTag("Wound") then
                    local rem = kopile.remainder
                    rem.flip()
                    rem.setPosition(getObjectFromGUID(woundsDeckGUID).getPosition())
                    totake = 0
                else
                    totake = totake - 1
                end
            else
                local spystack = getObjectFromGUID(woundsDeckGUID)
                if spystack then
                    if spystack.tag == "Deck" then
                        spystack.takeObject({position = pos,
                            flip=true})
                        if spystack.remainder then
                            woundsDeckGUID = spystack.remainder.guid
                        end
                    else
                        spystack.flip()
                        spystack.setPositionSmooth(pos)
                    end
                else
                    broadcastToAll("Wounds stack ran out.")
                end
            end
        end
        broadcastToAll("Master Strike: Wounds were added to the HQ!")
    end
    if epicness then
        local kopile = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        if kopile[1] and kopile[2] then
            broadcastToAll("Please merge the KO pile into a single deck.")
            return nil
        elseif kopile[1] and kopile[1].tag == "Deck" then
            for _,o in pairs(kopile[1].getObjects()) do
                for _,tag in pairs(o.tags) do
                    if tag == "Wound" then
                        table.insert(kodwounds,o.guid)
                        break
                    end
                end
            end
        elseif kopile[1] then
            if kopile[1].hasTag("Wound") and getObjectFromGUID(woundsDeckGUID) then
                kopile[1].flip()
                local pos = getObjectFromGUID(woundsDeckGUID).getPosition()
                pos.y = pos.y + 2
                kopile[1].setPosition(pos)
            end
        end
        Wait.time(vultureWounds,1)
    else
        vultureWounds()
    end
    return strikesresolved
end