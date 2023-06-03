function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids",
        "pos_discard"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    local guids3 = {
        "playguids",
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

function killInfinityGemButton(params)
    local obj = params.obj
    obj.clearButtons()
    obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
    Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city') end,2)
    Wait.time(shardAllGems,4)
    for _,b in pairs(discardGemguids) do
        if b ~= obj.guid then
            local card = getObjectFromGUID(b)
            if card then
                card.clearButtons()
                card.locked = false
                card.setPosition(getObjectFromGUID(playerBoards[latestGemColor]).positionToWorld(pos_discard))
            end
        end
    end
    local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[latestGemColor])
    if playcontent[1] then
        for _,o in pairs(playcontent) do
            if o.hasTag("Group:Infinity Gems") and o.guid ~= obj.guid then
                o.clearButtons()
            end
        end
    end
end

function shardAllGems()
    broadcastToAll("Scheme Twist: Shards added to all Infinity Gems in the city.")
    local city = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
    table.remove(city,1)
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if obj.hasTag("Group:Infinity Gems") then
                    getObjectFromGUID(pushvillainsguid).Call('gainShard2',{zoneGUID = o})
                    break
                end
            end
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local city = params.city
    
    local gemfound = false
    local color = Turns.turn_color
    latestGemColor = nil
    while gemfound == false do
        color = getObjectFromGUID(pushvillainsguid).Call('getNextColor',color)
        if color == Turns.turn_color then
            shardAllGems()
            gemfound = true
        end
        latestGemColor = color
        local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[color])
        if playcontent[1] then
            for _,o in pairs(playcontent) do
                if o.hasTag("Group:Infinity Gems") then
                    o.createButton({click_function = 'killInfinityGemButton',
                        function_owner=self,
                        position={0,22,0},
                        label="Pick",
                        tooltip="Pick this Infinity Gem to re-enter the city.",
                        font_size=250,
                        font_color="Black",
                        color={1,1,1},
                        width=750,height=450})
                    gemfound = true
                end
            end
        end
        local discarded = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
        discardGemguids = {}
        if discarded[1] and discarded[1].tag == "Deck" then
            for _,o in pairs(discarded[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k == "Group:Infinity Gems" then
                        gemfound = true
                        table.insert(discardGemguids,o.guid)
                        break
                    end
                end
            end
            if discardGemguids[1] then
                getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = color,
                    pile = discarded[1],
                    guids = discardGemguids,
                    resolve_function = 'killInfinityGemButton',
                    tooltip = "Pick this Infinity Gem to re-enter the city.",
                    fsourceguid = self.guid})
            end
        elseif discarded[1] then
            if discarded[1].hasTag("Group:Infinity Gems") then
                gemfound = true
                table.insert(discardGemguids,discarded[1].guid)
                discarded[1].createButton({click_function = 'killInfinityGemButton',
                        function_owner=self,
                        position={0,22,0},
                        label="Pick",
                        tooltip="Pick this Infinity Gem to re-enter the city.",
                        font_size=250,
                        font_color="Black",
                        color={1,1,1},
                        width=750,height=450})
            end
        end
    end
    broadcastToAll("Scheme Twist: The first player with an Infinity Gem Artifact card in play or in their discard pile chooses one of those Infinity Gems to enter the city.")
    return twistsresolved
end