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
    local strikeloc = params.strikeloc

    local madsbs = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    if madsbs[1] then
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    end
    for i =1,4 do
        getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = strikeloc,
            posabsolute = true})
    end
    return strikesresolved
end
