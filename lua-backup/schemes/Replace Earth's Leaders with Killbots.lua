function onLoad()   
    boost = 3
    
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
end

function nonTwist(params)
    local obj = params.obj
    local twistsstacked = params.twistsstacked
    
    if obj.hasTag("Bystander") then
        obj.addTag("Villain")
        obj.addTag("Killbot")
        obj.removeTag("Bystander")
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = boost + twistsstacked,
            tooltip = "This bystander is a Killbot and has power equal to the number of twists stacked next to the scheme."})
    end
    return 1
end

function resolveTwist(params)
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
    return nil
end