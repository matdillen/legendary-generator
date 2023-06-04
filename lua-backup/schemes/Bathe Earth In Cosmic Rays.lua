function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_discard",
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function batheNextPlayer(params)
    local index = params.index
    local color = params.player_clicker_color
    if index then
        getObjectFromGUID(hqguids[index]).Call('click_draw_hero')
    end
    local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',color)
    if nextcolor ~= Turns.turn_color then
        batheTheEarth(nextcolor)
    end
end
    
function pickNewHero(params)
    local obj = params.obj
    local index = params.index
    local color = params.player_clicker_color
    
    local cost = hasTag2(obj,"Cost:")
    local heroes = {}
    for i,h in pairs(hqguids) do
        local hero = getObjectFromGUID(h).Call('getHeroUp')
        if hasTag2(hero,"Cost:") <= cost then
            heroes[i] = hero
        end
    end
    local playerBoard = getObjectFromGUID(playerBoards[color])
    local dest = playerBoard.positionToWorld(pos_discard)
    dest.y = dest.y + 3
    local candn = 0
    for _,o in pairs(heroes) do
        candn = candn + 1
    end
    if candn > 1 then
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = color,
            hand = heroes,
            pos = dest,
            label = "Gain",
            tooltip = "Gain this hero.",
            trigger_function = 'batheNextPlayer',
            args = "self",
            buttoncolor = color,
            fsourceguid = self.guid})
        broadcastToColor("Choose a hero in the HQ to gain.",color,color)
    elseif candn == 1 then
        local zoneguid = nil
        local hero = nil
        for i,o in pairs(heroes) do
            zoneguid = i
            hero = o
        end
        hero.setPositionSmooth(dest)
        broadcastToColor("You gained the only eligible hero from the HQ (" .. hero.getName() .. ").",color,color)
        batheNextPlayer({obj = hero,
            index = zoneguid,
            player_clicker_color = color})
    else
        broadcastToColor("No eligible hero in the HQ to gain.",color,color)
        batheNextPlayer({player_clicker_color = color})
    end
end

function batheTheEarth(color)
    local hand = Player[color].getHandObjects()
    local handi = table.clone(hand)
    local iter = 0
    for i,obj in ipairs(handi) do
        if not hasTag2(obj,"HC:") then
            table.remove(hand,i-iter)
            iter = iter + 1
        end
    end
    if hand[1] then
        broadcastToColor("KO a non-grey hero from your hand.",color,color)
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = color,
            hand = hand,
            pos = getObjectFromGUID(kopile_guid).getPosition(),
            label = "KO",
            tooltip = "KO this card.",
            trigger_function = 'pickNewHero',
            args = "self",
            fsourceguid = self.guid})
    else
        broadcastToColor("No non-grey heroes in your hand to KO.",color,color)
        batheNextPlayer({player_clicker_color = color})
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    batheTheEarth(Turns.turn_color)
    broadcastToAll("Scheme Twist: Each player in turn KOs a non-grey Hero, then selects one from the HQ with equal cost or less and gains it.")
    return twistsresolved
end