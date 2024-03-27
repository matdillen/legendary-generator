function onLoad()
    local guids3 = {
        "playerBoards",
        "vpileguids",
        "playguids",
        "resourceguids",
        "attackguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
    
    local guids2 = {
       "allTopBoardGUIDS",
       "topBoardGUIDs",
       "city_zones_guids",
       "hqguids",
       "hqscriptguids",
       "pos_discard"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
    
    local guids1 = {
       "bystandersPileGUID",
       "kopile_guid",
       "escape_zone_guid",
       "officerDeckGUID",
       "strikeZoneGUID",
       "pushvillainsguid",
       "heroDeckZoneGUID",
       "setupGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    mmZoneGUID = self.guid
    
    addMMGUIDS = {}
    
    for _,o in pairs(allTopBoardGUIDS) do
        addMMGUIDS[o] = false
    end
    
    masterminds = {}
    transformed = {}
    mmLocations = {}
end

function returnVar(var)
    return _G[var]
end

function returnColor()
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    return getObjectFromGUID(setupGUID).Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
end

function click_update_tactics(obj)
    local mmdeck = getObjectFromGUID(setupGUID).Call('get_decks_and_cards_from_zone',obj.guid)
    local butt = obj.getButtons()
    local index = nil
    for i,o in pairs(butt) do
        if o.click_function == "click_update_tactics" then
            index = i-1
            break
        end
    end
    if index and mmdeck[1] and mmdeck[2] then
        for _,o in pairs(mmdeck) do
            if o.is_face_down and not o.hasTag("Bystander") and (hasTag2(o,"Tactic:") or o.tag == "Deck") then
                local c = math.abs(o.getQuantity())
                obj.editButton({index=index,label="(" .. c .. ")"})
                return nil
            end
        end
    elseif index and mmdeck[1] then
        if mmGetCards(mmdeck[1].getName()) == 4 or 
            (hasTag2(mmdeck[1],"Tactic:") and mmGetCards(hasTag2(mmdeck[1],"Tactic:")) == 4) or
            mmGetCards(mmdeck[1].getName(),nil,true) or
            (hasTag2(mmdeck[1],"Tactic:") and mmGetCards(hasTag2(mmdeck[1],"Tactic:"),nil,true)) then
            obj.editButton({index=index,label="(" .. math.abs(mmdeck[1].getQuantity()) .. ")"})
        else
            obj.editButton({index=index,label="(" .. math.abs(mmdeck[1].getQuantity())-1 .. ")"})
        end
    elseif index then
        obj.editButton({index=index,label="(" .. 0 .. ")"})
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateHQ(guid)
    hqguids = table.clone(getObjectFromGUID(guid).Call('returnVar',"hqguids"))
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

function updateMasterminds(mmname)
    table.insert(masterminds,mmname)
end

function removeMasterminds(index)
    table.remove(masterminds,index)
end

function updateMastermindsLocation(mmname,location)
    if mmname[1] then
        location = mmname[2]
        mmname = mmname[1]
    end
    if not mmLocations then
        mmLocations = {[mmname] = location}
    else
        mmLocations[mmname] = location
    end
    if addMMGUIDS[location] then
        addMMGUIDS[location] = true
    end
end

function removeMastermindsLocation(mmname)
    local iter = 1
    for i,o in ipairs(mmLocations) do
        if i == mmname then
            table.remove(mmLocations,iter)
            if addMMGUIDS[o] then
                addMMGUIDS[o] = false
            end
            break
        end
        iter = iter + 1
    end
end

function lockTopZone(guid)
    addMMGUIDS[guid] = true
end

function mmActive(mmname)
    for _,o in pairs(masterminds) do
        if o == mmname or o == mmname .. " - epic" then
            return true
        end
    end
    return false
end

function mmGetCards(mmname,transf,movingmm)
    if movingmm and mmname == "King Hyperion" then
        return true
    elseif movingmm then
        return false
    end
    if transf and (mmname == "General Ross" or mmname == "Illuminati, Secret Society" or mmname == "King Hulk, Sakaarson" or mmname == "M.O.D.O.K." or mmname == "The Red King" or mmname == "The Sentry") then
        return true
    elseif transf then
        return false
    else
        mmcardnumber = 5
        if mmname == "Hydra High Council" or mmname == "Hydra Super-Adaptoid" then
            mmcardnumber = 4
        end
        return(mmcardnumber)
    end
end

function isTransformed(mmname)
    return mmGetCards(mmname,true)
end

function returnTransformed(mmname)
    return transformed[mmname]
end

function returnMMLocation(mmname)
    return mmLocations[mmname]
end

function woundedFury(params)
    if not params then
        params = "empty"
    end
    local color = params.color or Turns.turn_color
    local asbonus = params.asbonus
    
    local discardpile = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
    local wounds = 0
    local buttonindex = nil
    if discardpile[1] and discardpile[1].tag == "Deck" then
        for _,o in pairs(discardpile[1].getObjects()) do
            if o.tags[1] == "Wound" then
                wounds = wounds + 1
            end
        end
    elseif discardpile[1] then
        if discardpile[1].hasTag("Wound") then
            wounds = wounds + 1
        end
    end
    
    if not asbonus then
        return wounds
    else
        return {"woundedFury",
        wounds,
        "Gets +1 for each wound in your discard pile."}
    end
end

function transformMM(obj)
    local content = get_decks_and_cards_from_zone(obj.guid,true)
    for i,o in pairs(content) do
        if o.getName() == "Shard" then
            bump(o)
            table.remove(content,i)
        end
    end
    if content[1] then
        for _,o in pairs(content) do
            if o.tag == "Card" and not hasTag2(o,"Tactic:",8) then
                o.flip()
                transformed[o.getName()] = not transformed[o.getName()]
                --log(transformed)
                transformChanges(o.getName())
                return transformed[o.getName()]
            elseif o.tag == "Deck" then
                for _,k in pairs(o.getObjects()) do
                    local istactic = false
                    for _,tag in pairs(k.tags) do
                        if tag:find("Tactic:") then
                            istactic = true
                            break
                        end
                    end
                    if istactic == false then
                        local pos = content[1].getPosition()
                        pos.y = pos.y + 1
                        o.takeObject({position = pos,
                            flip=true})
                        transformed[k.name] = not transformed[k.name]
                        --log(transformed)
                        transformChanges(k.name)
                        return transformed[k.name]
                    end
                end
            end
        end
    end
end

function transformChanges(name)
    if name == "General Ross" then
        getObjectFromGUID(getStrikeloc(name)).Call('updateMMRoss')
    elseif name == "Illuminati, Secret Society" then
        getObjectFromGUID(getStrikeloc(name)).Call('updateMMIlluminatiSS')
    elseif name == "King Hulk, Sakaarson" then
        getObjectFromGUID(getStrikeloc(name)).Call('updateMMHulk')
    elseif name == "M.O.D.O.K." then
        getObjectFromGUID(getStrikeloc(name)).Call('updateMMMODOK')
    elseif name == "The Red King" then
        getObjectFromGUID(getStrikeloc(name)).Call('updateMMRedKing')
    elseif name == "The Sentry" then
        getObjectFromGUID(getStrikeloc(name)).Call('updateMMSentry')
    end
end

function addTransformButton(zone)
    zone.createButton({click_function='transformMM',
        function_owner=self,
        position={0,0,1.2},
        rotation={0,180,0},
        label="Transform",
        tooltip="Transform the Mastermind.",
        font_size=100,
        font_color={0,0,0},
        color="Green",
        width=600,
        height=150})
end

function setupTransformingMM(mmname,mmZone,lurking)
    if not mmZone then
        mmZone = getObjectFromGUID(mmZoneGUID)
    end
    if not lurking then
        addTransformButton(mmZone)
    end
    transformed[mmname] = false
end

function setupMasterminds(params)
    local obj = params.obj
    local epicness = params.epicness
    local tactics = params.tactics
    local lurking = params.lurking
    local notscripted = params.notscripted
    
    local objname = obj.getName()
    local strikezone = getObjectFromGUID(getStrikeloc(objname))
    local script = obj.getLuaScript()
    
    local baselabel = setMMBasePower({obj = obj})
    mmButtons({mmname = objname,
        checkvalue = 1,
        label = baselabel,
        tooltip = "Base power as written on the card.",
        f = 'updatePower',
        id = 'card'})

    if not notscripted then
        obj.setLuaScript("")
        obj.reload()
        strikezone.setLuaScript(script)
        newstrikezone = strikezone.reload()
        Wait.condition(function()
            if newstrikezone.getVar("setupMM") then
                newstrikezone.Call('setupMM',{epicness = epicness})
            end
        end,
        function()
            if newstrikezone.getVar("onLoad") then
                return true
            else
                return false
            end
        end) 
    end
    if not tactics then
        tactics = 4
    end
    if tactics ~= 0 then
        getObjectFromGUID(mmLocations[objname]).createButton({
            click_function="click_update_tactics", function_owner=self,
            position={0,0,1}, rotation={0,180,0}, height=250, color={0,0,0,0.75},
            label = "(" .. tactics .. ")",font_color = {1,0.1,0,1}, tooltip="Remaining tactics. Click to force update."
        })
    end
    if not lurking then
        fightButton(mmLocations[objname])
    end
    if mmGetCards(objname,true) == true then
        setupTransformingMM(objname,getObjectFromGUID(mmLocations[objname]),lurking)
        return nil
    end
    if objname == "'92 Professor X" then
        if mmLocations[objname] == mmZoneGUID then
            strikeloc = strikeZoneGUID
        else
            for i,o in pairs(allTopBoardGUIDS) do
                if o == mmLocations[objname] then
                    strikeloc = allTopBoardGUIDS[i-1]
                    break
                end
            end
        end
        function click_buy_pawn92(obj,player_clicker_color)
            local hulkdeck = get_decks_and_cards_from_zone(obj.guid)[1]
            if not hulkdeck then
                return nil
            end
            local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
            local dest = playerBoard.positionToWorld(pos_discard)
            dest.y = dest.y + 3
            if hulkdeck.tag == "Card" then
                hulkdeck.setPositionSmooth(dest)
            else
                hulkdeck.takeObject({position=dest,flip=false,smooth=true})
            end
        end
        getObjectFromGUID(strikeloc).createButton({
             click_function="click_buy_pawn92", 
             function_owner=self,
             position={0,0,-0.75},
             rotation={0,180,0},
             label="Buy Pawn",
             tooltip="Buy the top card of '92 Professor X's telepathic pawns.",
             color={1,1,1,1},
             width=800,
             height=200,
             font_size = 100
        })
        function updateMMProfessorX92()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            if mmLocations[objname] == mmZoneGUID then
                strikeloc = strikeZoneGUID
            else
                for i,o in pairs(allTopBoardGUIDS) do
                    if o == mmLocations[objname] then
                        strikeloc = allTopBoardGUIDS[i-1]
                        break
                    end
                end
            end
            local bs = get_decks_and_cards_from_zone(strikeloc)
            local boost = 0
            if bs[1] then
                boost = math.abs(bs[1].getQuantity())
            end
            getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "'92 Professor X gets +1 for each of his telepathic pawns.",
                f = 'updateMMProfessorX92'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMProfessorX92,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMProfessorX92,0.1)
        end
        return nil
    end
end

function updatePower()
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
end

function setMMBasePower(params)
    local obj = params.obj
    local zoneguid = params.zoneguid

    if zoneguid then
        local zonecontent = Global.Call('get_decks_and_cards_from_zone',zoneguid)
        for _,o in pairs(zonecontent) do
            if o.hasTag("Mastermind") then
                obj = o
                break
            end
        end
    end
    if not obj then
        --broadcastToAll("Mastermind not found?")
        return nil
    end
    local objcontent = nil
    local baselabel = ""
    if obj.tag == "Deck" then
        objcontent = obj.getObjects()
    else
        baselabel = hasTag2(obj,"Power:") or ""
        if epicness then
            baselabel = hasTag2(o,"Epic:") or hasTag2(o,"Epicpower:")
        end
    end
    if objcontent then
        for _,o in pairs(objcontent) do
            local mmfound = false
            local tacticfound = false
            baselabel = 0
            for _,t in pairs(o.tags) do
                if t == "Mastermind" then
                    mmfound = true
                end
                if t:find("Tactic:") then
                    tacticfound = true
                end
                if t:find("Power:") and not epicness then
                    baselabel = tonumber(t:match("%d+")) or ""
                end
                if epicness and (t:find("Epicpower:") or t:find("Epic:")) then
                    baselabel = tonumber(t:match("%d+")) or ""
                end
            end
            if mmfound and not tacticfound then
                break
            end
        end
    end
    return tostring(baselabel)
end

function mmButtons(params)
    local mmname = params.mmname
    local checkvalue = params.checkvalue
    local label = tostring(params.label)
    local tooltip = params.tooltip
    local f = params.f
    local id = params.id or "base"
    local f_owner = params.f_owner or self
    
    local mmzone = getObjectFromGUID(mmLocations[mmname])
    if not mmzone then
        return nil
    end
    local buttonindex = nil
    local toolt_orig = {}
    if mmzone.getButtons() then
        for i,o in pairs(mmzone.getButtons()) do
            if o.click_function == f or (f == "mm" and o.click_function:find("updateMM")) or o.click_function == "updatePower" then
                buttonindex = i-1
                if o.tooltip:find("\n") then
                    for t in string.gmatch(o.tooltip,"[^\n]+") do
                        local tip = (t:gsub("%[.*",""))
                        local box = (t:gsub(".*%[",""))
                        box = (box:gsub("%]",""))
                        toolt_orig[(box:gsub(":.*",""))] = {(box:gsub(".*:","")),tip}
                    end
                else
                    local tip = (o.tooltip:gsub("%[.*",""))
                    local box = (o.tooltip:gsub(".*%[",""))
                    box = (box:gsub("%]",""))
                    toolt_orig[(box:gsub(":.*",""))] = {(box:gsub(".*:","")),tip}
                end
                if f == "mm" then
                    f = o.click_function
                    f_owner = o.function_owner
                end
                break
            end
        end
    end
    if not toolt_orig["card"] then
        local baselabel = setMMBasePower({zoneguid = mmLocations[mmname]})
        toolt_orig["card"] = {baselabel,"Base power as written on the card."}
    end
    local cards = Global.Call('get_decks_and_cards_from_zone',mmzone.guid)
    local shardfound = false
    for _,obj in pairs(cards) do
        if obj.getName() == "Shard" then
            local val = obj.Call('returnVal')
            toolt_orig["shard"] = {"+" .. val,"Power bonus from shards here."}
            shardfound = true
        end
    end
    if shardfound == false and toolt_orig["shard"] then
        toolt_orig["shard"] = nil
    end
    if f == "mm" then
        f = 'updatePower'
    end
    if checkvalue == 0 then
        label = ""
    end
    if label and tooltip and not toolt_orig then
        log("error")
        toolt_orig = {[id] = {label,tooltip}}
    elseif label and tooltip then
        toolt_orig[id] = {label,tooltip}
    end
    local lab,tool = updateLabel(toolt_orig)
    if not buttonindex then
        mmzone.createButton({click_function=f,
            function_owner=f_owner,
            position={0,0,0},
            rotation={0,180,0},
            label=lab,
            tooltip=tool,
            font_size=350,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
    else
        mmzone.editButton({index=buttonindex,label = lab,tooltip = tool})
    end
end

function updateLabel(tooltip)
    local sum = 0
    local aster = false
    local plus = true
    for i,o in pairs(tooltip) do
        if o[1] == "" then
            tooltip[i] = nil
        else
            if not o[1]:find("+") and o[1] ~= "*" then
                plus = false
            end
            if o[1]:find("*") then
                aster = true
            end
            if o[1]:find("-") then
                sum = sum - tonumber(o[1]:match("%d+"))
            elseif o[1]:find("X") then
                sum = "X"
                break
            elseif o[1] and o[1]:match("%d+") then
                sum = sum + tonumber(o[1]:match("%d+"))
            end
        end
    end
    if sum == 0 then
        sum = ""
    end
    if aster and sum ~= "X" then
        sum = sum .. "*"
    end
    if plus and sum ~= "X" and sum ~= "" and sum ~= "*" then
        sum = "+" .. sum
    end
    local newtooltip = ""
    for i,o in pairs(tooltip) do
        if o then
            if newtooltip ~= "" then
                newtooltip = newtooltip .. "\n" .. o[2] .. "[" .. i .. ":" .. o[1] .. "]"
            else
                newtooltip = o[2] .. "[" .. i .. ":" .. o[1] .. "]"
            end
        end
    end
    if not newtooltip then
        newtooltip = ""
    end
    return sum,newtooltip
end

function fightButton(zone)
    local butt = getObjectFromGUID(zone).getButtons()
    if butt then
        for _,o in pairs(butt) do
            if o.click_function:find("fightEffect") then
                return nil
            end
        end
    end
    _G["fightEffect" .. zone] = function(obj,player_clicker_color)
        local strikeloc = nil
        local mmname
        for i,o in pairs(mmLocations) do
            if o == obj.guid then
                mmname = i
                strikeloc = getStrikeloc(i)
                break
            end
        end
        if not strikeloc then
            return nil
        end
        local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
        if mmname == "M.O.D.O.K." and returnTransformed(mmname) == true then
            attack = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
        end
        local power = 0
        for _,o in pairs(get_decks_and_cards_from_zone(obj.guid)) do
            if o.tag == "Deck" then
                for _,p in pairs(o.getObjects()) do
                    local mmfound = false
                    local tacticfound = false
                    power = 0
                    for _,t in pairs(p.tags) do
                        if t == "Mastermind" then
                            mmfound = true
                        end
                        if t:find("Tactic:") then
                            tacticfound = true
                        end
                        if t:find("Power:") then
                            power = tonumber(t:match("%d+")) or 0
                        end
                    end
                    if mmfound and not tacticfound then
                        break
                    end
                end
            else
                if o.hasTag("Mastermind") and not hasTag2(o,"Tactic:") then
                    power = hasTag2(o,"Power:") or 0
                    break
                end
            end
        end
        if obj.getButtons() then
            for _,b in pairs(obj.getButtons()) do
                if b.click_function == "updatePower" then
                    if b.label:match("%d+") and b.label:find("+") then
                        power = power + tonumber(b.label:match("%d+"))
                    elseif b.label:match("%d+") and not b.label:find("-") then
                        power = tonumber(b.label:match("%d+"))
                    elseif b.label:match("%d+") then
                        power = power - tonumber(b.label:match("%d+"))
                    elseif b.label == "X" then
                        broadcastToColor("You can't fight this mastermind right now due to some restriction!",player_clicker_color,player_clicker_color)
                        return nil
                    end
                end
            end
        end
        if attack < power then
            broadcastToColor("You don't have enough attack to fight this mastermind!",player_clicker_color,player_clicker_color)
            return nil
        end
        if getObjectFromGUID(strikeloc).getVar("fightRestriction") then
            local goahead = getObjectFromGUID(strikeloc).Call('fightRestriction',{color = player_clicker_color})
            if not goahead then
                broadcastToColor("Fight restriction of mastermind not met!", player_clicker_color, player_clicker_color)
                return nil
            end
        end
        if mmname == "M.O.D.O.K." and returnTransformed(mmname) == true then
            getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-power)
        else
            getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-power)
        end
        if not scheme then
            scheme = getObjectFromGUID(setupGUID).Call('returnVar',"scheme")
        end
        if scheme.getVar("fightEffect") then
            scheme.Call('fightEffect',{obj = obj,color = player_clicker_color,mm = true})
        end
        local name = fightMM(obj.guid,player_clicker_color)
        Wait.time(function() click_update_tactics(obj) end,1)
        --log("name:")
        --log(name)
        if name then
            local killFightButton = function()
                local content = get_decks_and_cards_from_zone(obj.guid,false,false)
                local finalblow = getObjectFromGUID(setupGUID).Call('returnVar',"finalblow")
                if not content[1] or (not finalblow and content[1].tag == "Card" and content[1].getName() == name and not content[2]) then
                    broadcastToAll(name .. " was defeated!")
                    if strikeloc.getVar("mmDefeated") then
                        strikeloc.Call('mmDefeated')
                    end
                    if content[1] then
                        if content[1].is_face_down then
                            content[1].flip()
                        end
                        koCard(content[1])
                    end
                    for i,o in pairs(masterminds) do
                        if o == name then
                            table.remove(masterminds,i)
                            break
                        end
                    end
                    addMMGUIDS[mmLocations[name]] = false
                    mmLocations[name] = nil
                    if transformed[name] then
                        transformed[name] = nil
                    end
                    for i,o in ipairs(obj.getButtons()) do
                        if o.click_function:find("fightEffect") or o.click_function == "transformMM" then
                            obj.removeButton(i-1)
                        elseif o.click_function:find("updateMM") or o.click_function == "updatePower" then
                            obj.removeButton(i-1)
                        elseif o.click_function == "click_update_tactics" then
                            obj.removeButton(i-1)
                        end
                    end
                    local strikecontent = get_decks_and_cards_from_zone(strikeloc)
                    if strikecontent[1] then
                        strikecontent[1].destruct()
                    end
                    local strikeZone = getObjectFromGUID(strikeloc)
                    local strikebutt = strikeZone.getButtons()
                    local iter2 = 0
                    if strikebutt then
                        for i,o in ipairs(strikebutt) do
                            if o.click_function:find("updateMM") then
                                strikeZone.removeButton(i-1-iter2)
                                iter2 = iter2 + 1
                            end
                        end
                    end
                    strikeZone.setLuaScript("")
                    strikeZone.reload()
                    --obj.clearButtons()
                    if table.clone(getObjectFromGUID(setupGUID).Call('returnVar',"setupParts"))[1] == "World War Hulk" then
                        if not scheme then
                            scheme = getObjectFromGUID(setupGUID).Call('returnVar',"scheme")
                        end
                        scheme.Call('addNewLurkingMM') 
                    end
                elseif transformed[name] ~= nil then
                    transformMM(getObjectFromGUID(mmLocations[name]))
                elseif mmGetCards(name) == 4 then
                    content[1].randomize()
                end
            end
            Wait.time(killFightButton,1)
        end
    end
    getObjectFromGUID(zone).createButton({click_function="fightEffect" .. zone,
        function_owner=self,
        position={0,0,0.5},
        rotation={0,180,0},
        label="Fight",
        tooltip="Fight this card.",
        font_size=200,
        font_color="Red",
        color={0,0,0},
        width=600,height=375})
end

function bump(obj,y)
    if not y then
        y = 2
    end
    local pos = obj.getPosition()
    pos.y = pos.y + y
    obj.setPositionSmooth(pos)
end

function koCard(obj,smooth)
    if smooth then
        obj.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
    else
        obj.setPosition(getObjectFromGUID(kopile_guid).getPosition())
    end
end

function fightMM(zoneguid,player_clicker_color)
    local content = get_decks_and_cards_from_zone(zoneguid,true)
    for i,o in pairs(content) do
        if o.getName() == "Shard" then
            bump(o)
            table.remove(content,i)
        end
    end
    local vppos = getObjectFromGUID(vpileguids[player_clicker_color]).getPosition()
    vppos.y = vppos.y + 2
    local name = nil
    for i,o in pairs(mmLocations) do
        if o == zoneguid and mmActive(i) then
            name = i
            break
        end
    end
    local thetacticstays = false
    if name == "King Hyperion" then
        for i,o in pairs(city_zones_guids) do
            if i > 1 then
                local citycontent = get_decks_and_cards_from_zone(o)
                if citycontent[1] then
                    for _,obj in pairs(citycontent) do
                        if obj.getName() == "King Hyperion" then
                            obj.setPositionSmooth(getObjectFromGUID(zoneguid).getPosition())
                            thetacticstays = true
                            for _,obj2 in pairs(citycontent) do
                                if obj2.getName() ~= "King Hyperion" and not obj2.getDescription():find("LOCATION") then
                                    koCard(obj2)
                                end
                            end
                            break
                        end
                    end
                    if thetacticstays == true then
                        break
                    end
                end
            end
        end
    end
    if content[1] and content[2] then
        for i,o in pairs(content) do
            if o.tag == "Deck" then
                if i == 1 then
                    bump(content[2])
                else
                    bump(content[1])
                end
                if thetacticstays == true then
                    resolveTactics(name,o.getObjects()[1].name,player_clicker_color,true)
                    o.randomize()
                    return nil
                else
                    o.takeObject({position = vppos,
                        flip = o.is_face_down,
                        smooth = true})
                    return name
                end
            elseif o.tag == "Card" and hasTag2(o,"Tactic:",8) then
                if thetacticstays == true then
                    resolveTactics(name,o.getName(),player_clicker_color,true)
                    return nil
                else
                    o.setPositionSmooth(vppos)
                    if o.is_face_down then
                        Wait.time(function() o.flip() end,0.8)
                    end
                    return name
                end
            end
        end
    elseif content[1] then
        if content[1].tag == "Deck" then
            for i,o in pairs(content[1].getObjects()) do
                local tacticFound = false
                for _,k in pairs(o.tags) do
                    if k:find("Tactic:") then
                        tacticFound = true
                        break
                    end
                end
                if tacticFound == false then
                    if thetacticstays == true then
                        resolveTactics(name,content[1].getObjects()[i+1].name,player_clicker_color,true)
                        local pos = content[1].getPosition()
                        pos.y = pos.y + 2
                        local shufflethetactics = function()
                            if content[1] then
                                content[1].randomize()
                            end
                        end
                        content[1].takeObject({position = pos,
                            smooth = true,
                            callback_function = shufflethetactics})
                        return nil
                    else
                        content[1].takeObject({position = vppos,
                            index = i,
                            flip = content[1].is_face_down,
                            smooth = true})
                        if content[1].remainder then
                            content[1] = content[1].remainder
                        end
                        return name
                    end
                end
            end
            if thetacticstays == true then
                resolveTactics(name,content[1].getObjects()[1].name,player_clicker_color,true)
                content[1].randomize()
                return nil
            else
                content[1].takeObject({position = vppos,
                    flip = content[1].is_face_down,
                    smooth = true})
                return name
            end
        else
            if thetacticstays == true then
                resolveTactics(name,content[1].getName(),player_clicker_color,true)
                return nil
            else
                if content[1].getName():find("Ascended Baron") then
                    local name = content[1].getName():sub(16,-1):match("[^%b()]+")
                    content[1].setName(name)
                end
                content[1].setPositionSmooth(vppos)
                if content[1].is_face_down then
                    Wait.time(function() content[1].flip() end,0.8)
                end
                return name
            end
        end
    end
    return nil
end

function getStrikeloc(mmname)
    local strikeloc = nil
    if mmLocations[mmname] == mmZoneGUID then
        strikeloc = strikeZoneGUID
    else
        for i,o in pairs(allTopBoardGUIDS) do
            if o == mmLocations[mmname] then
                strikeloc = allTopBoardGUIDS[i-1]
                break
            end
        end
    end
    return strikeloc
end

function getNextMMLoc()
    for guid,occup in pairs(addMMGUIDS) do
        if occup == false then
            for index,guid2 in pairs(allTopBoardGUIDS) do
                if guid2 == guid and index % 2 == 0 and addMMGUIDS[allTopBoardGUIDS[index-1]] == false then
                    addMMGUIDS[guid] = true
                    addMMGUIDS[allTopBoardGUIDS[index-1]] = true
                    return guid
                end
            end
        end
    end
    broadcastToAll("No location found for an extra mastermind.")
    return nil
end

function resolveTactics(mmname,tacticname,color,stays)
    if mmname[1] then
        tacticname = mmname[2]
        color = mmname[3]
        stays = mmname[4]
        mmname = mmname[1]
    end
    if mmname == "King Hyperion" and stays then
        if tacticname == "Monarch of Utopolis" then
            for i = 1,3 do
                getObjectFromGUID(playerBoards[color]).Call('handsizeplus')
            end
            broadcastToColor("No tactic earned, as the King was in the city, but you'll draw three extra cards next turn.",color,color)
        elseif tacticname == "Rule with an iron fist" then
            broadcastToColor("No tactic earned, as the King was in the city, but you may defeat a villain the city for free (unscripted).",color,color)
        elseif tacticname == "Worshipped by millions" then
            for i = 1,6 do
                getObjectFromGUID(pushvillainsguid).Call('getBystander',color)
            end
            broadcastToColor("No tactic earned, as the King was in the city, but you rescue six bystanders.",color,color)
        elseif tacticname == "Royal treasury" then
            getObjectFromGUID(resourceguids[color]).Call('addValue',5)
            broadcastToColor("No tactic earned, as the King was in the city, but you gained 5 Recruit.",color,color)
        end
        return nil
    end
    if mmname == "Maximus the Mad" then
        if tacticname == "Seize the inhuman throne" then
            local thronesfavor = getObjectFromGUID(setupGUID).Call('returnVar',"thronesfavor")
            local val = 4
            if thronesfavor == "mmMaximus the Mad" then
                val = 3
            end
            getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",
                player_clicker_color = "mmMaximus the Mad"})
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                log(o.color)
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,n = #hand-val})
            end
            broadcastToAll("Maximus Fight effect: Maximus seizes the inhuman throne! Each player discards down to " .. val .. " cards.")
        elseif tacticname == "Terrigen bomb" then
            bump(get_decks_and_cards_from_zone(heroDeckZoneGUID)[1])
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero and (not hasTag2(hero,"Attack:") or hasTag2(hero,"Attack:") < 2) then
                    getObjectFromGUID(o).Call('tuckHero')
                end
            end
            local thronesfavor = getObjectFromGUID(setupGUID).Call('returnVar',"thronesfavor")
            if thronesfavor == "mmMaximus the Mad" then
                for _,o in pairs(Player.getPlayers()) do
                    local hand = o.getHandObjects()
                    local toKO = {}
                    for _,obj in pairs(hand) do
                        if hasTag2(obj,"Attack:") and hasTag2(obj,"HC:") then
                            table.insert(toKO,obj)
                        end
                    end
                    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                        hand = toKO,
                        pos = getObjectFromGUID(kopile_guid).getPosition(),
                        label = "KO",
                        tooltip = "KO this card."})
                end
                broadcastToAll("Maximus Fight effect: Maximus deploys the Terrigen Bomb! Weak heroes with attack less than 2 are blown away from the HQ. As he had the Throne's Favor, each player KO's a non-grey hero with an attack symbol.")
            else
                broadcastToAll("Maximus Fight effect: Maximus deploys the Terrigen Bomb! Weak heroes with attack less than 2 are blown away from the HQ.")
            end
            getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",
                player_clicker_color = "mmMaximus the Mad"})
            
        elseif tacticname == "Echo-tech chorus sentries" then
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                local toKO = {}
                for _,obj in pairs(hand) do
                    if (hasTag2(obj,"HC:") and hasTag2(obj,"HC:") == "Silver") or (hasTag2(obj,"Team:") and hasTag2(obj,"Team:") == "Inhumans") then
                        table.insert(toKO,obj)
                    end
                end
                local play = get_decks_and_cards_from_zone(playguids[o.color])
                if play[1] then
                    for _,obj in pairs(play) do
                        if (hasTag2(obj,"HC:") and hasTag2(obj,"HC:") == "Silver") or (hasTag2(obj,"Team:") and hasTag2(obj,"Team:") == "Inhumans") then
                            table.insert(toKO,obj)
                        end
                    end
                end
                if #toKO == 0 then
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                else
                    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                        hand = toKO,
                        pos = getObjectFromGUID(kopile_guid).getPosition(),
                        label = "KO",
                        tooltip = "KO this card"})
                end
            end
            broadcastToAll("Maximus Fight effect: Maximus deploys the Echo-Tech Chorus Sentries. Each player KOs a silver or Inhumans hero or gains a wound.")
        elseif tacticname == "Sieve of secrets" then
            for _,o in pairs(Player.getPlayers()) do
                local playerBoard = getObjectFromGUID(playerBoards[o.color])
                local posdiscard = playerBoard.positionToWorld(pos_discard)
                local deck = playerBoard.Call('returnDeck')[1]
                local hoodDiscards = function()
                    if not deck then
                        deck = playerBoard.Call('returnDeck')[1]
                    end
                    local deckcards = deck.getObjects()
                    local todiscard = {}
                    for i=1,6 do
                        for _,k in pairs(deckcards[i].tags) do
                            if k:find("HC:") or k == "Split" then
                                table.insert(todiscard,deckcards[i].guid)
                                break
                            end
                        end
                    end
                    if todiscard[1] then
                        for i=1,#todiscard do
                            deck.takeObject({position = posdiscard,
                                flip = true,
                                smooth = true,
                                guid = todiscard[i]})
                            if deck.remainder and i < #todiscard then
                                deck.remainder.flip()
                                deck.remainder.setPositionSmooth(posdiscard)
                            end
                        end
                    end
                end
                if deck and deck.getQuantity() > 5 then
                    hoodDiscards()
                else
                    playerBoard.Call('click_refillDeck')
                    deck = nil
                    Wait.time(hoodDiscards,2)
                end
           end
           broadcastToAll("Maximus Fight effect: Maximus deploys the Sieve of Secrets. Each player discards all non-grey heroes from the top 6 cards of their deck.")
        else
            printToAll("Unknown tactic found? (" .. tacticname[1] .. ").")
        end
        return nil
    end
end