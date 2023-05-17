function onLoad()
    vildeckcount = 0
    wwiiInvasion = false
    
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "villainDeckZoneGUID"
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
        "playguids"
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

function killGrey(params)
    sacrificed = sacrificed + 1
    goodSacrifice(sacrificed)
end

function killNonGrey(params)
    sacrificed = sacrificed + 1
    goodSacrifice(sacrificed)
end

function goodSacrifice(sac)
    for _,o in pairs(herosacrifices) do
        for i,b in pairs(o.getButtons) do
            if b.click_function:find("discardCard") then
                o.removeButton(i-1)
                break
            end
        end
    end
    if sac == 2 then
        broadcastToAll(color .. " player sacrificed two heroes for the Soul Stone and saved a hero in the HQ from the mastermind!")
        thetwist.locked = false
        thetwist.flip()
        local vilpos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
        thetwist.setPosition(vilpos)
        getObjectFromGUID(playerBoards[color]).Call('click_draw_cards',3)
        Wait.time(
            function()
                local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
                vildeck.randomize()
                getObjectFromGUID(pushvillainsguid).Call('playVillains')
            end,1)
    end
end

function sacrificeSoul(params)
    sacrificed = -1
    broadcastToAll("The mastermind sacrificed a hero from the HQ!")
    for _,o in pairs(grey) do
        for i,b in pairs(o.getButtons) do
            if b.click_function:find("discardCard") then
                o.removeButton(i-1)
                break
            end
        end
    end
    for _,o in pairs(nongrey) do
        for i,b in pairs(o.getButtons) do
            if b.click_function:find("discardCard") then
                o.removeButton(i-1)
                break
            end
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    thetwist = params.cards
    
    thetwist.locked = true
    
    sacrificed = 0
    grey = {}
    nongrey = {}
    herosacrifices = {}
    color = Turns.turn_color
    
    local pos = getObjectFromGUID(kopile_guid).getPosition()
    pos.y = pos.y + 2
    local pos2 = getObjectFromGUID(twistZoneGUID).getPosition()
    pos2.y = pos2.y + 2
    
    local hand = Player[color].getHandObjects()
    for _,o in pairs(hand) do
        if not hasTag2(o,"HC:") and (o.hasTag("Hero") or o.hasTag("Starter") then
            table.insert(grey,o)
        elseif hasTag2(o,"HC:") then
            table.insert(nongrey,o)
        end
    end
    local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[color])
    if playcontent[1] then
        for _,o in pairs(playcontent) do
            if not hasTag2(o,"HC:") and (o.hasTag("Hero") or o.hasTag("Starter") then
                table.insert(grey,o)
            elseif hasTag2(o,"HC:") then
                table.insert(nongrey,o)
            end
        end
    end
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then
            broadcastToAll("Hero missing in hq!")
            return nil
        end
        table.insert(herosacrifices,hero)
    end
    if #grey > 0 and #nongrey > 0 then
        broadcastToColor("Scheme Twist: KO one of your grey and one of your nongrey heroes, or sacrifice a hero in the HQ for the mastermind.",color,color)
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = color,
            hand = grey,
            label = "KO",
            tooltip = "KO this grey hero.",
            pos = pos,
            trigger_function = 'killGrey',
            buttoncolor = "Grey",
            args = "self",
            fsourceguid = self.guid})
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = color,
            hand = nongrey,
            label = "KO",
            tooltip = "KO this nongrey hero.",
            pos = pos,
            buttoncolor = "Purple",
            trigger_function = 'killNonGrey',
            args = "self",
            fsourceguid = self.guid})
    else
        broadcastToColor("Scheme Twist: You don't have enough grey and/or nongrey heroes, so sacrifice a hero in the HQ for the mastermind.",color,color)
    end
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = color,
        hand = herosacrifices,
        label = "Sacrifice",
        tooltip = "Sacrifice this hero to the Soul Stone.",
        pos = pos2,
        buttoncolor = "Red",
        trigger_function = 'sacrificeSoul',
        args = "self",
        fsourceguid = self.guid})
    return nil
end