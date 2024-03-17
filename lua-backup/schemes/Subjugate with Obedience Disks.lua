function onLoad()   
    local guids1 = {
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS",
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function setupSpecial(params)
    local dividedDeckGUIDs = {
        ["HC:Red"]="4c1868",
        ["HC:Green"]="8656c3",
        ["HC:Yellow"]="533311",
        ["HC:Blue"]="3d3ba7",
        ["HC:Silver"]="725c5d"
    }
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 3,7 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
    for i,o in pairs(dividedDeckGUIDs) do
        getObjectFromGUID(o).createButton({
            click_function="obedienceDisk",
            function_owner=self,
            tooltip="Put the Obedience Disks (Scheme Twists) here.",
            position={0,-0.4,0},
            height=550,
            width=500,
            color={0,1,0,0.6}})
    end
end

function obedienceDisk(obj,player_clicker_color)
    broadcastToColor("Heroes in the HQ zone below this one cost 1 more for each Obedience Disk (twist) here.",
        player_clicker_color,
        player_clicker_color)
    return nil
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
