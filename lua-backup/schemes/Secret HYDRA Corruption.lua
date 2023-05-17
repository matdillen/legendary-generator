function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "officerDeckGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local twistpile = getObjectFromGUID(twistZoneGUID)
    if twistsresolved == 1 then
        officerdeck = getObjectFromGUID(officerDeckGUID)
        twistpile.createButton({click_function="updatePower",
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,180,0},
            label="3",
            tooltip="Pay 3 Recruit to have any player gain one of these Officers.",
            font_size=350,
            font_color="Yellow",
            color={0,0,0,0.75},
            width=250,height=250})
    end
    if self.is_face_down == false then
        self.flip()
        twistpile.editButton({tooltip = "Fight for 3 to return any of these officers to the Officer deck and KO one of your heroes.",
            font_color = "Red"})
    else
        self.flip()
        twistpile.editButton({tooltip = "Pay 3 Recruit to have any player gain one of these Officers.",
            font_color = "Yellow"})
    end
    for i = 1,twistsresolved do
        if officerdeck.getQuantity() > 1 then
            officerdeck.takeObject({position=twistpile.getPosition(),
                flip=true,
                smooth=true})
            if officerdeck.remainder then
                officerdeck = officerdeck.remainder
            end
        else
            officerdeck.flip()
            officerdeck.setPositionSmooth(twistpile.getPosition())
            officerdeck = nil
            break
        end
    end
    if not officerdeck then
        broadcastToAll("Officer deck ran out. Evil wins!",{1,0,0})
    end
    return twistsresolved
end
