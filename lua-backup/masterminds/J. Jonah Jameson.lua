function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playerBoards"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
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

function shuffleIntoMobs(params)
    local obj = params.obj
    obj.setPosition(getObjectFromGUID(getStrikeloc(mmname)).getPosition())
    obj.flip()
    if epicness and (not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") == 0) then
        getObjectFromGUID(pushvillainsguid).Call('getWound',params.player_clicker_color)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    mmname = params.mmname
    epicness = params.epicness

    for _,o in pairs(Player.getPlayers()) do
        local investigateMobs = function()
            local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')[1]
            local deckcontent = deck.getObjects()
            local investiguids = {deckcontent[1].guid,deckcontent[2].guid}
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                pile = deck,
                guids = investiguids,
                resolve_function = 'shuffleIntoMobs',
                tooltip = "Shuffle this card into the Angry Mobs stack.",
                label = "Shuffle",
                args = "self",
                flip = true,
                fsourceguid = self.guid})
        end
        local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
        if not deck[1] or deck[1].getQuantity() < 2 then
            getObjectFromGUID(playerBoards[o.color]).Call('refillDeck')
            Wait.time(investigateMobs,1)
        else
            investigateMobs()
        end
    end
    return strikesresolved
end
