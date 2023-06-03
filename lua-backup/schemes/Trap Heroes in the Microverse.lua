function onLoad()   
    local guids1 = {
        "pushvillainsguid"
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
    
    if hasTag2(obj,"Team:",6) then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = hasTag2(obj,"Cost:") .. "*",
            tooltip = "This hero is a villain with power equal to its cost and Size-Changing for its colors. Gain it if you fight it."})
        if obj.getDescription() == "" then
            obj.setDescription("SIZE-CHANGING: This card costs 2 less to Recruit or Fight if you have a Hero with the listed Hero Class. Different colors can stack.")
        else
            obj.setDescription(obj.getDescription() .. "\r\nSIZE-CHANGING: This card costs 2 less to Recruit or Fight if you have a Hero with the listed Hero Class. Different colors can stack.")
        end
    end
    return 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    return twistsresolved
end