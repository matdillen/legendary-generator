function onLoad()
    strikesstacked = 0
    
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
        strikesstacked = strikesstacked + 1
    end
    getObjectFromGUID(pushvillainsguid).Call('demolish',{n = strikesstacked})
    return nil
end