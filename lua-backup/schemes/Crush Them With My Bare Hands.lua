function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local cards = params.cards
    cards[1].setName("Masterstrike")
    broadcastToAll("Scheme Twist: This Scheme Twist is a Master Strike!")
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    return nil
end