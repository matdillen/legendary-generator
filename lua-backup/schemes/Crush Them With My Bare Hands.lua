function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Strikes resolved: __/8."}
    else
        return getObjectFromGUID(pushvillainsguid).Call('returnVar',"strikesresolved")
    end
end

function resolveTwist(params)
    local cards = params.cards
    cards[1].setName("Masterstrike")
    broadcastToAll("Scheme Twist: This Scheme Twist is a Master Strike!")
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    return nil
end