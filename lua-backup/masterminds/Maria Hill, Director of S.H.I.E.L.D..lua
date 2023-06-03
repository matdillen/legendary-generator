function onLoad()
    mmname = "Maria Hill, Director of S.H.I.E.L.D."
    
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID",
        "mmZoneGUID"
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

function updateMMMaria()
    local shieldfound = 0
    for _,o in pairs(city_zones_guids) do
        if o ~= city_zones_guids[1] then
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if obj.hasTag("Officer") or obj.HasTag("Group:S.H.I.E.L.D. Elite") then
                        shieldfound = shieldfound + 1
                        break
                    end
                end
            end
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = shieldfound,
        label = "X",
        tooltip = "You can't fight Maria Hill while there are any S.H.I.E.L.D. Elite Villains or Officers in the city.",
        f = 'updateMMMaria',
        f_owner = self})
end

function setupMM()
    updateMMMaria()
    function onObjectEnterZone(zone,object)
        if object.hasTag("Officer") or obj.hasTag("Group:S.H.I.E.L.D. Elite") then
            updateMMMaria()
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.hasTag("Officer") or obj.hasTag("Group:S.H.I.E.L.D. Elite") then
            updateMMMaria()
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local officerdeck = getObjectFromGUID(officerDeckGUID)
    local pushOfficer = function(obj)
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = 3,
            tooltip = "This Officer is a villain. Gain it if you fight it."})
        obj.addTag("Villain")
        getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    end
    local takeOfficer = function()
        officerdeck.takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
            flip = true,
            smooth = true,
            callback_function = pushOfficer})
    end
    takeOfficer()
    Wait.time(takeOfficer,2)
    return strikesresolved
end