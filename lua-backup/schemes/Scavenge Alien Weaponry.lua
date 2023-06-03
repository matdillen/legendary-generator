function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function nonTwist(params)
    local obj = params.obj
    
    local schemeParts = table.clone(getObjectFromGUID(setupGUID).Call('returnVar',"setupParts"))
    
    if obj.getName() == schemeParts[9] then
        obj.setName("Smugglers")
        if obj.getDescription() == "" then
            obj.setDescription("STRIKER: Get 1 extra Power for each Master Strike in the KO pile or placed face-up in any zone.")
        else
            obj.setDescription(obj.getDescription() .. "\r\nSTRIKER: Get 1 extra Power for each Master Strike in the KO pile or placed face-up in any zone.")
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = "+" .. params.strikesresolved,
            tooltip = "Smuggler villains have striker and thus get +1 for each master strike resolved.",
            id = "striker"})
    end
    return 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    return twistsresolved
end