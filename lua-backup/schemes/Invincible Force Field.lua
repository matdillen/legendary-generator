function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved == 1 then
        local mmzone = getObjectFromGUID(twistZoneGUID)
        mmzone.createButton({click_function="updatePower",
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0.5,0,0},
            rotation={0,180,0},
            label="+1/",
            tooltip="Spend this much Recruit (or Attack) to fight the Mastermind.",
            font_size=350,
            font_color="Yellow",
            color={0,0,0,0.75},
            width=250,height=250})
        mmzone.createButton({click_function="updatePower",
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={-0.5,0,0},
            rotation={0,180,0},
            label="+1",
            tooltip="Spend this much Attack (or Recruit) to fight the Mastermind.",
            font_size=350,
            font_color="Red",
            color={0,0,0,0.75},
            width=250,height=250})
    elseif twistsresolved < 7 then
        local mmzone = getObjectFromGUID(twistZoneGUID)
        mmzone.editButton({index = 0,
            label = "+" .. twistsresolved .. "/"})
        mmzone.editButton({index = 1,
            label = "+" .. twistsresolved})
    else
        broadcastToAll("Scheme Twist: Evil Wins!")
    end
    return nil
end
