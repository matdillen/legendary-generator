function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck and vildeck.tag == "Deck" then
        local pos = self.getPosition()
        local strangeguids = {}
        pos.x = pos.x - 6
        pos.y = pos.y + 3
        local insertGuid = function(obj)
            local objname = obj.getName()
            if objname == "" then
                objname = "an unnamed card"
            end
            broadcastToAll("Master Strike: Shiklah revealed " .. objname .. " from the villain deck!")
            table.insert(strangeguids,obj.guid)
        end
        for i=1,3 do
            pos.x = pos.x + 2
            vildeck.takeObject({position = pos,
                flip=true,
                smooth=true,
                callback_function = insertGuid})
        end
        local strangeguidsEntered = function()
            if strangeguids and #strangeguids == 3 then
                return true
            else
                return false
            end
        end
        local strangeProcess = function()
            Global.Call('bump',{obj = vildeck,y = 4})
            for _,o in pairs(strangeguids) do
                local object = getObjectFromGUID(o)
                if object.getName() == "Scheme Twist" then
                    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
                    pos.y = pos.y + 6
                    object.flip()
                    object.setPositionSmooth(pos)
                else
                    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
                    object.flip()
                    object.setPositionSmooth(pos)
                end
            end
        end
        Wait.condition(strangeProcess,strangeguidsEntered)
    end
    return strikesresolved
end
