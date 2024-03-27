function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck and vildeck.tag == "Deck" then
        local pos = self.getPosition()
        local strangeguids = {}
        local strangecount = 3
        pos.x = pos.x - 6
        pos.y = pos.y + 3
        local insertGuid = function(obj)
            local objname = obj.getName()
            if objname == "" then
                objname = "an unnamed card"
            end
            broadcastToAll("Master Strike: Dr. Strange revealed " .. objname .. " from the villain deck!")
            table.insert(strangeguids,obj.guid)
        end
        for i=1,3 do
            pos.x = pos.x + 2
            vildeck.takeObject({position = pos,
                flip=true,
                smooth=true,
                callback_function = insertGuid})
            if vildeck.remainder then
                vildeck = vildeck.remainder
                if i < 3 then
                    vildeck.flip()
                    pos.x = pos.x + 2
                    vildeck.setPositionSmooth(pos)
                    insertGuid(vildeck)
                    if i == 1 then
                        strangecount = 2
                    end
                end
                break
            end
        end
        local strangeguidsEntered = function()
            if strangeguids and #strangeguids == strangecount then
                return true
            else
                return false
            end
        end
        local strangeProcess = function()
            local twistfound = false
            local powerguid = nil
            local power = 0
            for i,o in pairs(strangeguids) do
                local object = getObjectFromGUID(o)
                if twistfound == false and object.getName() == "Scheme Twist" then
                    twistfound = true
                    local moveTwist = function()
                        object.setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                    end
                    Wait.time(moveTwist,1)
                    strangeguids[i] = nil
                elseif object.hasTag("Villain") then
                    if not powerguid then
                        powerguid = i
                        if hasTag2(object,"Power:") then
                            power = hasTag2(object,"Power:")
                        end
                    elseif hasTag2(object,"Power:") and hasTag2(object,"Power:") > power then
                        powerguid = i
                        power = hasTag2(object,"Power:")
                    end
                end
            end
            if vildeck then
                Global.Call('bump',{obj = vildeck,y = 4})
            end
            if powerguid then
                local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
                pos.y = pos.y + 6
                local object = getObjectFromGUID(strangeguids[powerguid])
                object.flip()
                object.setPositionSmooth(pos)
                strangeguids[powerguid] = nil
            end
            for _,o in pairs(strangeguids) do
                local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
                local object = getObjectFromGUID(o)
                object.flip()
                object.setPositionSmooth(pos)
            end
        end
        Wait.condition(strangeProcess,strangeguidsEntered)
    elseif vildeck.getName() == "Scheme Twist" then
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    end
    return strikesresolved
end