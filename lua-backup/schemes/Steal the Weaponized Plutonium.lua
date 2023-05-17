function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    cards[1].setDescription("VILLAINOUS WEAPON: This plutonium gives +1. Shuffle it back into the villain deck if the villain holding it is defeated.")
    getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
        label = "+1",
        tooltip = "This plutonium gives +1. Shuffle it back into the villain deck if the villain holding it is defeated."})
    --these will often become stacks and that will kill the button...
    getObjectFromGUID(pushvillainsguid).Call('playVillains')
    return twistsresolved
end
