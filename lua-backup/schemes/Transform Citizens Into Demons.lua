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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function nonTwist(params)
    local obj = params.obj
    
    if obj.getName() == "Jean Grey (DC)" then
        if not goblincount then
            goblincount = 0
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = hasTag2(obj,"Cost:")+goblincount,
            tooltip = "Jean Grey heroes are villains with power equal to their cost + the number of goblin villains next to the scheme. They are worth VP, not gained as heroes when fought."})
        obj.addTag("Villain")
        obj.addTag("VP4")
    end
    return 1
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