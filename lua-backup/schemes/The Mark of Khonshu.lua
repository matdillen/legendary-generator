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
    
    if hasTag2(obj,"Cost:") then
        obj.addTag("Villain")
        obj.addTag("Khonshu Guardian")
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = hasTag2(obj,"Cost:")*2,
            tooltip = "This hero is a Khonshu Guardian villain. Its power is equal to its cost, or twice its cost when in Wolf form."})
    end
    return 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    return twistsresolved
end