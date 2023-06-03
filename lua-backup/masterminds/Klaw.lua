function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    local frequencies = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    frequencies.flip()
    local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)
    if herodeck[1] then
        Global.Call('bump',{obj = herodeck[1]})           
    end
    frequencies.setPositionSmooth(getObjectFromGUID(heroDeckZoneGUID).getPosition())
    local klawDiscard = function(obj,index,color)
        local frequency_colors = hasTag2(obj,"HC:")
        local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',frequency_colors)
        if epicness then
            players = Player.getPlayers()
        end
        for _,o in pairs(players) do
            getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
        end
        if epicness then
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHero')
                if not hasTag2(hero,"HC:") == frequency_colors then
                    getObjectFromGUID(o).Call('tuckHero')
                end
            end
        end
    end
    if herodeck[1] and herodeck[1].tag == "Deck" then
        herodeck[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
            flip = true,
            callback_function = klawDiscard})
    elseif herodeck[1] and herodeck[1].tag == "Card" then
        herodeck[1].flip()
        herodeck[1].setPosition(getObjectFromGUID(strikeloc).getPosition())
        klawDiscard(herodeck[1])
    end
    return strikesresolved
end
