function onLoad()
    mmname = "Maximus the Mad"
    
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "strikePileGUID",
        "mmZoneGUID"
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

function updateMMMaximus()
    local power = 0
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            for _,k in pairs(hero.getTags()) do
                if k:find("Attack:") then
                    power = math.max(power,tonumber(k:match("%d+")))
                end
                if k:find("Attack1:") then
                    power = math.max(power,tonumber(k:match("%d+")))
                end
                if k:find("Attack2:") then
                    power = math.max(power,tonumber(k:match("%d+")))
                end
            end
        end
    end
    local boost = ""
    if epicness then
        power = power*2
        boost = " twice "
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = power,
        label = "+" .. power,
        tooltip = "Maximus gets extra Attack equal to" .. boost .. "the highest printed Attack of all heroes in the HQ.",
        f = 'updateMMMaximus',
        id = "highestabomination",
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    updateMMMaximus()
    function onObjectEnterZone(zone,object)
        updateMMMaximus()
    end
    function onObjectLeaveZone(zone,object)
        updateMMMaximus()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local mmloc = params.mmloc

    local content = Global.Call('get_decks_and_cards_from_zone2',{zoneGUID = mmloc,bsinc = false})
    local tacticguids = {}
    local deck = nil
    if content[1] and content[2] then
        for _,o in pairs(content) do
            if o.tag == "Deck" then
                local deck = o.getObjects()
                local card = table.remove(deck,math.random(#deck))
                table.insert(tacticguids,card.guid)
                broadcastToAll("Master Strike: Random tactic \"" .. card.name .. "\" was revealed")
                if epicness then
                    local card2 = table.remove(deck,math.random(#deck))
                    table.insert(tacticguids,card2.guid)
                    broadcastToAll("Master Strike: Random tactic \"" .. card2.name .. "\" was also revealed")
                end
                deck = o
                break
            elseif o.tag == "Card" and hasTag2(o,"Tactic:") then
                broadcastToAll("Master Strike: Only remaining tactic \"" .. o.getName() .. "\" was revealed")
                if o.getVar("tacticEffect") then
                    o.Call('tacticEffect')
                end
                return strikesresolved
            end
        end
    elseif content[1] then
        if content[1].tag == "Deck" then
            local deck = content[1].getObjects()
            for i,o in pairs(deck) do
                local tacticFound = false
                for _,k in pairs(o.tags) do
                    if k:find("Tactic:") then
                        tacticFound = true
                        break
                    end
                end
                if tacticFound == false then
                    table.remove(deck,i)
                    break
                end
            end
            local card = table.remove(deck,math.random(#deck))
            table.insert(tacticguids,card.guid)
            broadcastToAll("Master Strike: Random tactic \"" .. card.name .. "\" was revealed")
            if epicness then
                local card2 = table.remove(deck,math.random(#deck))
                table.insert(tacticguids,card2.guid)
                broadcastToAll("Master Strike: Random tactic \"" .. card2.name .. "\" was also revealed")
            end
            deck = content[1]
        end
    end
    if tacticguids[1] and deck then
        local pos = mmloc.getPosition()
        pos.y = pos.y + 4
        local resolveTacticEffect = function(obj)
            obj.locked = true
            if deck.remainder then
                deck = deck.remainder
            end
            Wait.condition(
                function()
                    obj.flip()
                    if obj.getVar("tacticEffect") then
                        obj.Call("tacticEffect")
                    end
                    obj.locked = false
                    deck.putObject(obj)
                    Wait.time(function() deck.randomize() end,1)
                end,
                function()
                    if obj.spawning then
                        return false
                    else
                        return true
                    end
                end
            )
        end
        deck.takeObject({position = pos,
            flip = true,
            smooth = false,
            guid = tacticguids[1],
            callback_function = resolveTacticEffect})
        if epicness and tacticguids[2] then
            epicMaxTactic = function(obj)
                obj.clearButtons()
                getObjectFromGUID(pushvillainsguid).Call('koCard',obj)
                deck.takeObject({position = pos,
                    flip = true,
                    smooth = false,
                    guid = tacticguids[2],
                    callback_function = resolveTacticEffect})
            end
            if not cards[1] then
                cards[1] = getObjectFromGUID(strikePileGUID).takeObject({position = self.getPosition(),
                    smooth = false})
            end
            cards[1].createButton({click_function="epicMaxTactic",
                function_owner=self,
                position={0,22,0},
                label="Tactic2",
                tooltip="Resolve the second tactic's effect",
                font_size=500,
                font_color={1,0,0},
                color={1,1,1},
                width=1500,height=400})
            return nil
        end
    end
    return strikesresolved
end