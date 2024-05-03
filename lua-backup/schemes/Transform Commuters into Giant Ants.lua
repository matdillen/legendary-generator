function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function table.clone(org,key)
    if key then
        local new = {}
        for i,o in pairs(org) do
            new[i] = o
        end
        return new
    else
        return {table.unpack(org)}
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved == 1 then
        getObjectFromGUID(topBoardGUIDs[1]).createButton({click_function="updatePower",
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,180,0},
            label="2",
            tooltip="Fight for 2 to rescue one of these Giant Ant bystanders.",
            font_size=350,
            font_color="Red",
            color={0,0,0,0.75},
            width=250,height=250})
    end
    for i=1,twistsstacked do
        getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{pos = getObjectFromGUID(topBoardGUIDs[1]).getPosition(),
            face = false})
    end
    return nil
end