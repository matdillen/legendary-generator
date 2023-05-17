function onLoad()   
    local guids2 = {
        "allTopBoardGUIDS"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function updateHQTags()
    for i,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
        local content = Global.Call('get_decks_and_cards_from_zone',o)
        local zone = getObjectFromGUID(o)
        if content[1] and content[1].getQuantity() < 3 then
            if #zone.getButtons() == 1 then
                zone.createButton({click_function="updateHQTags",
                    function_owner=self,
                    position={0,0,-3.7},
                    rotation={0,180,0},
                    label="+" .. math.abs(content[1].getQuantity()),
                    tooltip="Additional cost due to subjugation disks",
                    font_size=300,
                    font_color="Yellow",
                    color={0,0,0,0.75},
                    width=250,height=250})
            else
                zone.editButton({index=1,label="+" .. math.abs(content[1].getQuantity())})
            end
        elseif content[1] and content[1].getQuantity() > 2 then
            broadcastToAll("Too many obedience disks in zone " .. i .. " above the board")
        elseif not content[1] and #zone.getButtons() > 1 then
            zone.removeButton(1)
        end
    end
end

function resolveTwist(params)
    broadcastToAll("Put this twist in one of the zones above the board. A zone cannot have more than two twists in it.")
    function onObjectEnterZone()
        updateHQTags()
        Wait.time(updateHQTags,1)
    end
    return nil
end
