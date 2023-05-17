function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    local herodeckzone = getObjectFromGUID(heroDeckZoneGUID)
    local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
    if twistsresolved % 2 == 0 and twistsresolved < 7 then
        broadcastToAll("Scheme Twist: Until next twist, heroes cost attack to recruit and enemies recruit to fight!")
        herodeckzone.createButton({click_function='updatePower',
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={4,0,0.5},
            rotation={0,180,0},
            scale={3,0.5,1.5},
            label="Heroes cost Attack to recruit!",
            tooltip="Play restriction because of Scheme Twist!",
            font_size=100,
            font_color={1,0.1,0},
            color={0,0,0},
            width=0})
        vildeckzone.createButton({click_function='updatePower',
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={3.4,0,0.5},
            rotation={0,180,0},
            scale={2.2,0.5,1.5},
            label="Enemies cost Recruit to fight!",
            tooltip="Play restriction because of Scheme Twist!",
            font_size=100,
            font_color="Yellow",
            color={0,0,0},
            width=0})
    elseif twistsresolved < 7 and twistsresolved > 1 then
        broadcastToAll("Scheme Twist: Resource reversions are relieved!")
        herodeckzone.clearButtons()
        vildeckzone.clearButtons()
    elseif twistsresolved == 7 then
        broadcastToAll("Evil Wins!")
    end
    return twistsresolved
end
