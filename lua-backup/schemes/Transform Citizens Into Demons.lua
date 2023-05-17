function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "bszoneguid",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    local bsPile = Global.Call('get_decks_and_cards_from_zone',bszoneguid)[1]
    if twistsresolved == 1 then
        getObjectFromGUID(twistZoneGUID).createButton({click_function="updatePower",
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,180,0},
            label="2",
            tooltip="Fight for 2 to rescue one of these bystanders.",
            font_size=350,
            font_color="Red",
            color={0,0,0,0.75},
            width=250,height=250})
        getObjectFromGUID(twistZoneGUID).createButton({click_function="updatePower",
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,1},
            rotation={0,180,0},
            label="(5)",
            tooltip="5 Bystanders remaining",
            font_size=350,
            font_color="White",
            color={0,0,0,0.75},
            width=250,height=250})
    end
    for i=1,5 do
        bsPile.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
            smooth = true})
    end
    function onObjectEnterZone(zone,object)
        if zone == getObjectFromGUID(twistZoneGUID) then
            local goblin = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
            if goblin[1] then
                goblincount = math.abs(goblin[1].getQuantity())
            else
                goblincount = 0
            end
            zone.editButton({index=1,
                label="(" .. goblincount .. ")",
                tooltip=goblincount .. " Bystanders remaining"})
            updatePower()
        end
    end
    function onObjectLeaveZone(zone,object)
        if zone == getObjectFromGUID(twistZoneGUID) then
            local goblin = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
            if goblin[1] then
                goblincount = math.abs(goblin[1].getQuantity())
            else
                goblincount = 0
            end
            zone.editButton({index=1,
                label="(" .. goblincount .. ")",
                tooltip=goblincount .. " Bystanders remaining"})
            updatePower()
        end
    end
    return twistsresolved
end
