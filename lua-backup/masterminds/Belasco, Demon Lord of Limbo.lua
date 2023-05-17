function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
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

function drawCard(color)
    getObjectFromGUID(playerBoards[color]).Call('click_draw_card')
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    local sunlight = 0
    local moonlight = 0
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            local cost = hasTag2(hero,"Cost:")
            if cost then
                if cost % 2 == 0 then
                    sunlight = sunlight + 1
                else
                    moonlight = moonlight + 1
                end
            end
        end
    end
    local light = sunlight - moonlight
    if light > 0 then
        for _,o in pairs(Player.getPlayers()) do
            local discardguids = {}
            local discarded = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
            --log("discard:")
            --log(discarded)
            if discarded[1] and discarded[1].tag == "Deck" then
                for _,c in pairs(discarded[1].getObjects()) do
                    for _,tag in pairs(c.tags) do
                        if tag:find("HC:") or tag == "Split" then
                            table.insert(discardguids,c.guid)
                            break
                        end
                    end
                end
                --log("discardguids " .. o.color)
                --log(discardguids)
                if discardguids[1] and discardguids[2] then
                    if epicness == true then
                        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                            pile = discarded[1],
                            guids = discardguids,
                            resolve_function = 'koCard',
                            tooltip = "KO this card.",
                            label = "KO",
                            n = 2})
                        broadcastToColor("Master Strike: Each player KOs two non-grey Heroes from their discard pile.",o.color,o.color)
                    else
                        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                            pile = discarded[1],
                            guids = discardguids,
                            resolve_function = 'koCard',
                            tooltip = "KO this card.",
                            label = "KO"})
                        broadcastToColor("Master Strike: Choose a card from your discard pile to be KO'd.",o.color,o.color)
                    end
                elseif discardguids[1] then
                    discarded[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                        guid = discardguids[1],
                        smooth = true})
                    broadcastToColor("Master Strike: The only non-grey hero from your discard pile was KO'd.",o.color,o.color)
                end
            elseif discarded[1] then
                if hasTag2(discarded[1],"HC:",4) then
                    getObjectFromGUID(pushvillainsguid).Call('koCard',discarded[1])
                    broadcastToColor("Master Strike: The only non-grey hero from your discard pile was KO'd.",o.color,o.color)
                end
            end
        end
    elseif light < 0 then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local nongrey = {}
            for _,obj in pairs(hand) do
                if hasTag2(obj,"HC:") then
                    table.insert(nongrey,obj)
                end
            end
            if nongrey[1] then
                local c = 1
                if epicness then
                    c = 2
                end
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = nongrey,
                    n = c,
                    pos = getObjectFromGUID(kopile_guid).getPosition(),
                    label = "KO",
                    tooltip = "Waking Nightmare, but this card will be KO'd by Belasco.",
                    trigger_function = 'drawCard',
                    args = o.color,
                    fsourceguid = self.guid})
            end
        end
    end
    return strikesresolved
end
