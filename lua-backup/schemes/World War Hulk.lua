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
        "topBoardGUIDs",
        "allTopBoardGUIDS"
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
    for i = 2,4 do
        lurkingLocations[lurkingMasterminds[i-1]] = topBoardGUIDs[2*i]
    end
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 3,8 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
    for i=2,4 do
        getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = lurkingMasterminds[i-1],
            pileGUID = mmPileGUID,
            destGUID = topBoardGUIDs[i*2],
            callbackf = "tyrantShuffleHulk",
            fsourceguid = self.guid})
    end
end

function tacticsKill(obj)
    local mmZone = getObjectFromGUID(mmZoneGUID)
    local decktokill = nil
    local zonetokill = nil
    for i=2,4 do
        if lurkingMasterminds[i-1] == obj.getName() then
            zonetokill = getObjectFromGUID(topBoardGUIDs[i*2])
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
    Wait.time(function()
        mmZone.Call('click_update_tactics',zonetokill)
    end,1)
end

function tyrantShuffleHulk(obj)
    if obj.getQuantity() == 4 then
        obj.randomize()
        obj.takeObject.destruct()
        obj.takeObject.destruct()
        Wait.time(function()
            getObjectFromGUID(mmZoneGUID).Call('click_update_tactics',getObjectFromGUID(mmLocations[obj.getName()]))
        end,1)
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

function getStrikeloc(mmname)
    local strikeloc = nil
    if lurkingLocations[mmname] == mmZoneGUID then
        strikeloc = strikeZoneGUID
    else
        for i,o in pairs(allTopBoardGUIDS) do
            if o == lurkingLocations[mmname] then
                strikeloc = allTopBoardGUIDS[i-1]
                break
            end
        end
    end
    return strikeloc
end

function updateMMZonePower(params)
    local baselabel = getObjectFromGUID(mmZoneGUID).Call('setMMBasePower',{zoneguid = params.targetguid})
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmzone = getObjectFromGUID(params.targetguid),
        checkvalue = 1,
        label = baselabel,
        tooltip = "Base power as written on the card.",
        f = 'updatePower',
        id = 'card'})
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
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
            local strikelurkingpos = getObjectFromGUID(getStrikeloc(currentmm)).getPosition()
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
                Global.Call('smoothMoveCheck',{obj = o,
                    targetguid = lurkingLocations[currentmm],
                    f = 'updateMMZonePower',
                    fsourceguid = self.guid})
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
        else
            local nomorelurkingzone = getObjectFromGUID(lurkingLocations[newmm])
            for i,o in ipairs(nomorelurkingzone.getButtons()) do
                if o.click_function == "transformMM" then
                    nomorelurkingzone.removeButton(i-1)
                elseif o.click_function:find("updateMM") or o.click_function == "updatePower" then
                    nomorelurkingzone.removeButton(i-1)
                elseif o.click_function == "click_update_tactics" then
                    nomorelurkingzone.removeButton(i-1)
                end
            end
            lurkingLocations[newmm] = nil
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
            Global.Call('smoothMoveCheck',{obj = o,
                targetguid = mmZoneGUID,
                f = 'updateMMZonePower',
                fsourceguid = self.guid})
        end
        local newstrikeposition = getObjectFromGUID(strikeZoneGUID).getPosition()
        local newstrikeloc = getStrikeloc(newmm)
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