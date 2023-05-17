function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID",
        "twistZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local officerdeck = getObjectFromGUID(officerDeckGUID)
    local twistpilecontent = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    if twistsresolved == 1 then
        getObjectFromGUID(twistZoneGUID).createButton({click_function="updatePower",
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,180,0},
            label="3",
            tooltip="Fight for 3 to gain any of these Officers as heroes or send them Undercover to your Victory Pile.",
            font_size=350,
            font_color="Red",
            color={0,0,0,0.75},
            width=250,height=250})
    end
    if twistpilecontent[1] then
        broadcastToAll("Scheme Twist: An Officer escaped! HYDRA level increased!")
        if twistpilecontent[1].tag == "Deck" then
            local bottomRest = function(obj)
                local twistpilecontent = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
                twistpilecontent[1].flip()
                twistpilecontent[1].setPositionSmooth(officerdeck.getPosition())
            end
            twistpilecontent[1].takeObject({position=getObjectFromGUID(escape_zone_guid).getPosition(),
                callback_function = bottomRest})
        else
            twistpilecontent[1].setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
        end
    end
    for i = 1,#Player.getPlayers() do
        officerdeck.takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
            flip=true})
    end
    return twistsresolved
end
