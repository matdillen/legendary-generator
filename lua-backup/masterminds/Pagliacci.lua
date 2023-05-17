function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local epicness = params.epicness

    if cards[1] then
        if strikesresolved == 1 or strikesresolved == 5 or (strikesresolved == 3 and epicness == true) then
            cards[1].setName("Scheme Twist")
            getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
            return nil
        end
    end
    if strikesresolved == 2 or strikesresolved == 4 or (strikesresolved == 3 and not epicness) then
        getObjectFromGUID(pushvillainsguid).Call('demolish')
    end
    return strikesresolved
end
