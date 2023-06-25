function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function nonTwist(params)
    local obj = params.obj
    
    if obj.hasTag("Bystander") then
        obj.addTag("Villain")
        obj.addTag("Killbot")
        obj.addTag("Power:3")
        obj.removeTag("Bystander")
    end
    return 1
end

function resolveTwist(params)
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
    return nil
end