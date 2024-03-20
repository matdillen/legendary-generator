function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "setupGUID",
        "mmPileGUID",
        "strikeZoneGUID"
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

function returnLurking()
    return lurkingMasterminds
end

function setupSpecial(params)
    getObjectFromGUID(setupGUID).Call('disable_finalblow')
    log("Moving extra masterminds outside game.")
    lurkingMasterminds = {}
    for s in string.gmatch(params.setupParts[9],"[^|]+") do
        table.insert(lurkingMasterminds, s)
    end
    log("lurkers = ")
    log(lurkingMasterminds)
    lurkingLocations = {}
    for i = 1,3 do
        lurkingLocations[lurkingMasterminds[i]] = topBoardGUIDs[2*i]
    end
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 1,6 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
    for i=1,3 do
        getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = lurkingMasterminds[i],
            pileGUID = mmPileGUID,
            destGUID = topBoardGUIDs[i*2],
            callbackf = "tyrantShuffleHulk",
            fsourceguid = self.guid})
    end
end

function tacticsKill(obj)
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i=1,3 do
        if lurkingMasterminds[i] == obj.getName() then
            local zonetokill = getObjectFromGUID(topBoardGUIDs[i*2])
            mmZone.Call('updateMastermindsLocation',{obj.getName(),topBoardGUIDs[i*2]})
            mmZone.Call('setupMasterminds',{obj = obj,epicness = false,tactics = 2,lurking = true})
            for j,o in pairs(zonetokill.getObjects()) do
                if o.name == "Deck" then
                    decktokill = zonetokill.getObjects()[j]
                    decktokill.flip()
                end
            end
        end
    end
    decktokill.randomize()
    decktokill.takeObject({index=0}).destruct()
    decktokill.takeObject({index=0}).destruct()
end

function tyrantShuffleHulk(obj)
    if obj.getQuantity() == 4 then
        obj.randomize()
        obj.takeObject.destruct()
        obj.takeObject.destruct()
    end
    if obj.getQuantity() == 5 then
        local posabove = obj.getPosition()
        posabove.y = posabove.y +2
        obj.takeObject({position=posabove,
            smooth=true,
            index=4,
            callback_function = tacticsKill})
    end
end

function addNewLurkingMM(currentmm)
    if lurkingMasterminds[1] then
        local newmm = table.remove(lurkingMasterminds,math.random(#lurkingMasterminds))
        local mmZone = getObjectFromGUID(mmZoneGUID)
        mmZone.Call('updateMasterminds',newmm)
        mmZone.Call('updateMastermindsLocation',{newmm,mmZoneGUID})
        if currentmm then
            table.insert(lurkingMasterminds,currentmm)
            lurkingLocations[currentmm] = lurkingLocations[newmm]
            mmZone.Call('removeMastermindsLocation',currentmm)
            local lurkingpos = getObjectFromGUID(lurkingLocations[currentmm]).getPosition()
            local strikelurkingpos = getObjectFromGUID(getStrikeloc(currentmm,lurkingLocations)).getPosition()
            for i,o in pairs(table.clone(mmZone.Call('returnVar',"masterminds"))) do
                if o == currentmm then
                    mmZone.Call('removeMasterminds',i)
                    break
                end
            end
            local mmcontent = Global.Call('get_decks_and_cards_from_zone',mmZoneGUID)
            for _,o in pairs(mmcontent) do
                if o.is_face_down == false then
                    lurkingpos.y = lurkingpos.y + 4
                else
                    lurkingpos.y = getObjectFromGUID(lurkingLocations[currentmm]).getPosition().y
                end
                o.setPositionSmooth(lurkingpos)
            end
            local strikecontent = Global.Call('get_decks_and_cards_from_zone',strikeZoneGUID)
            if strikecontent[1] then
                for _,o in pairs(strikecontent) do
                    o.setPositionSmooth(strikelurkingpos)
                    strikelurkingpos.y = strikelurkingpos.y + 4
                end
            end
            local strikeZone = getObjectFromGUID(strikeZoneGUID)
            local strikebutt = strikeZone.getButtons()
            local iter2 = 0
            if strikebutt then
                for i,o in ipairs(strikebutt) do
                    if o.click_function:find("update") and not o.click_function:find("Power") then
                        strikeZone.removeButton(i-1-iter2)
                        iter2 = iter2 + 1
                    end
                end
            end
        end
        local newmmposition = getObjectFromGUID(mmZoneGUID).getPosition()
        local newmmcontent = Global.Call('get_decks_and_cards_from_zone',lurkingLocations[newmm])
        for _,o in pairs(newmmcontent) do
            if o.is_face_down == false then
                newmmposition.y = newmmposition.y + 4
            else
                newmmposition.y = getObjectFromGUID(mmZoneGUID).getPosition().y
            end
            o.setPositionSmooth(newmmposition)
        end
        local newstrikeposition = getObjectFromGUID(strikeZoneGUID).getPosition()
        local newstrikeloc = getObjectFromGUID(pushvillainsguid).Call('getStrikeloc2',{mmname = newmm,
            alttable = lurkingLocations})
        local newstrikecontent = Global.Call('get_decks_and_cards_from_zone',newstrikeloc)
        if newstrikecontent[1] then
            for _,o in pairs(newstrikecontent) do
                o.setPositionSmooth(newstrikeposition)
                newstrikeposition.y = newstrikeposition.y + 4
            end
        end
        getObjectFromGUID(mmZoneGUID).Call('fightButton',mmZoneGUID)
        if getObjectFromGUID(mmZoneGUID).Call('isTransformed',newmm) == true then
            getObjectFromGUID(mmZoneGUID).Call('addTransformButton',getObjectFromGUID(mmZoneGUID))
        else
            local butt = getObjectFromGUID(mmZoneGUID).getButtons()
            for _,o in pairs(butt) do
                if o.click_function == "transformMM" then
                    getObjectFromGUID(mmZoneGUID).removeButton(o.index)
                    break
                end
            end
        end
        broadcastToAll("Scheme Twist: Mastermind was switched with a random lurking mastermind!")
    elseif not table.clone(mmZone.Call('returnVar',"masterminds"))[1] then
        broadcastToAll("No More masterminds found, so you WIN!")
    else
        broadcastToAll("No More lurking masterminds found.")
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 9 then
        local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
        for i,o in pairs(mmLocations) do
            if o == mmZoneGUID and getObjectFromGUID(mmZoneGUID).Call('mmActive',i) then
                addNewLurkingMM(i)
                break
            end
        end
    elseif twistsresolved == 9 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end