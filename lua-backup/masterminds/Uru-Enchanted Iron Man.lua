function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local cards = params.cards
    local strikeloc = params.strikeloc

    if cards[1] then
        cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
    end
    getObjectFromGUID(pushvillainsguid).Call('demolish')
    return nil
end
