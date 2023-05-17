function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "vpileguids"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local city = params.city
    
    local maxpower = 0
    local toAscend = nil
    local ascendCard = nil
    local mmpos = getObjectFromGUID(mmZoneGUID).Call('getNextMMLoc')
    if twistsresolved < 8 then
        for _,o in pairs(city) do
            local citycards = Global.Call('get_decks_and_cards_from_zone',o)
            if citycards[1] then
                local spacepower = 0
                for _,i in pairs(citycards) do
                    if hasTag2(i,"Power:") and not i.getDescription():find("LOCATION") then
                        spacepower = spacepower + hasTag2(i,"Power:")
                        if spacepower > maxpower then
                            toAscend = o
                            ascendCard = i
                            maxpower = spacepower
                            break
                        end
                    end
                end
            end
        end
        local escapee = false
        local escapedcards = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escapedcards[1] then
            if escapedcards[1].tag == "Deck" then
                for _,i in pairs(escapedcards[1].getObjects()) do
                    for _,j in pairs(i.tags) do
                        if j:find("Power:") then
                            local power = tonumber(j:match("%d+"))
                            if power > maxpower then
                                toAscend = i.guid
                                maxpower = power
                                escapee = true
                                break
                            end
                        end
                    end
                end
            else
                if hasTag2(escapedcards[1],"Power:") and hasTag2(escapedcards[1],"Power:") > maxpower then
                    toAscend = escape_zone_guid
                    ascendCard = escapedcards[1]
                    maxpower = hasTag2(escapedcards[1],"Power:")
                end
            end
        end
        if toAscend then
            if escapee == true then
                local annotateNewMM = function(obj)
                    local mmZone = getObjectFromGUID(mmZoneGUID)
                    obj.addTag("Ascended")
                    getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
                        label = hasTag2(obj,"Power:")+2,
                        tooltip = "This villain has ascended to become an Ascended Baron Mastermind and gets +2."})
                    mmZone.Call('fightButton',mmpos)
                    local vp = hasTag2(obj,"VP") or 0
                    mmZone.Call('updateMasterminds',"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")")
                    mmZone.Call('updateMastermindsLocation',{"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")",mmpos})
                end
                escapedcards[1].takeObject({position = getObjectFromGUID(mmpos).getPosition(),
                    guid = toAscend,
                    callback_function = annotateNewMM})
                broadcastToAll("Scheme Twist: Escaped villain ascended to become a mastermind!")
            else
                local vilgroup = Global.Call('get_decks_and_cards_from_zone',toAscend)
                local power = 0
                for i,o in pairs(vilgroup) do
                    if o.getDescription():find("LOCATION") then
                        table.remove(vilgroup,i)
                    elseif hasTag2(o,"Power:") then
                        o.addTag("Ascended")
                        power = power + hasTag2(o,"Power:")
                    end
                end
                local mmZone = getObjectFromGUID(mmZoneGUID)
                getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = ascendCard,
                    label = power+2,
                    tooltip = "This villain has ascended to become an Ascended Baron Mastermind and gets +2."})
                mmZone.Call('fightButton',mmpos)
                local vp = hasTag2(ascendCard,"VP") or 0
                mmZone.Call('updateMasterminds',"Ascended Baron " .. ascendCard.getName() .. "(" .. vp .. ")")
                mmZone.Call('updateMastermindsLocation',{"Ascended Baron " .. ascendCard.getName() .. "(" .. vp .. ")",mmpos})
                getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = table.clone(vilgroup),
                    targetZone = getObjectFromGUID(mmpos),
                    enterscity = 1,
                    schemeParts = {self.getName()})
                broadcastToAll("Scheme Twist: Villain in city ascended to become a mastermind!")
            end
        else
            broadcastToAll("Scheme Twist: No villains found.")
        end
    elseif twistsresolved == 8 then
        for i,o in pairs(vpileguids) do
            if Player[i].seated then
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
                if vpilecontent[1] then
                    local maxpower = 0
                    if vpilecontent[1].tag == "Deck" then
                        for _,k in pairs(vpilecontent[1].getObjects()) do
                            for _,j in pairs(k.tags) do
                                if j:find("Power:") then
                                    local power = tonumber(j:match("%d+"))
                                    toAscend = k.guid
                                    if power > maxpower then
                                        maxpower = power
                                    end
                                    break
                                end
                            end
                        end
                    else
                        if hasTag2(vpilecontent[1],"Power:") then
                            toAscend = o
                        end
                    end
                    local mmpos = getObjectFromGUID(mmZoneGUID).Call('getNextMMLoc')
                    if toAscend and mmpos then
                        broadcastToAll("Scheme Twist: Villain from " .. i .. "'s victory pile ascends!",i)
                        if vpilecontent[1].tag == "Deck" then
                            local annotateNewMM = function(obj)
                                local mmZone = getObjectFromGUID(mmZoneGUID)
                                obj.addTag("Ascended")
                                getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
                                    label = hasTag2(obj,"Power:")+2,
                                    tooltip = "This villain has ascended to become an Ascended Baron Mastermind and gets +2."})
                                mmZone.Call('fightButton',mmpos)
                                local vp = hasTag2(obj,"VP") or 0
                                mmZone.Call('updateMasterminds',"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")")
                                mmZone.Call('updateMastermindsLocation',{"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")",mmpos})
                            end
                            vpilecontent[1].takeObject({position = getObjectFromGUID(mmpos).getPosition(),
                                guid=toAscend,
                                callback_function = annotateNewMM})
                        else
                            vpilecontent[1].addTag("Ascended")
                            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = vpilecontent[1],
                                label = hasTag2(vpilecontent[1],"Power:")+2,
                                tooltip = "This villain has ascended to become an Ascended Baron Mastermind and gets +2."})
                            vpilecontent[1].setPositionSmooth(getObjectFromGUID(mmpos).getPosition())
                            local mmZone = getObjectFromGUID(mmZoneGUID)
                            mmZone.Call('fightButton',mmpos)
                            local vp = hasTag2(ascendCard,"VP") or 0
                            mmZone.Call('updateMasterminds',"Ascended Baron " .. vpilecontent[1].getName() .. "(" .. vp .. ")")
                            mmZone.Call('updateMastermindsLocation',{"Ascended Baron " .. vpilecontent[1].getName() .. "(" .. vp .. ")",mmpos})
                        end
                    elseif not toAscend then
                        broadcastToAll("Scheme Twist: No villains found in victory piles?")
                    elseif not mmpos then
                        broadcastToAll("Too many masterminds to deal with. YOU LOSE!!!")
                    end
                end
            end
        end
    end
    return twistsresolved
end