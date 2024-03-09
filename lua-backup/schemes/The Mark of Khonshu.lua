function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids3 = {
        "cityguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function bonusInCity(params)
    if params.object.hasTag("Khonshu Guardian") then
        local i = 1
        for name,o in pairs(cityguids) do
            if o == params.zoneguid and (name == "Sewers" or name == "Rooftops" or name == "Bridge") then
                i = 2
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{
            obj= params.object, 
            label = hasTag2(params.object,"Cost:")*i,
            zoneguid = params.zoneguid,
            tooltip = "This hero is marked by Khonshu and has double power in the Sewers, Rooftop or Bridge.",
            id = "khonshu"})
    end
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