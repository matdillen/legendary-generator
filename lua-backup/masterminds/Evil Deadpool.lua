function onLoad()
    mmname = "Evil Deadpool"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
     local guids3 = {
        "vpileguids"
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

function updateMMDeadpool()
    local color = Turns.turn_color
    local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[color])
    local tacticsfound = 0
    for i = 1,2 do
        if vpilecontent[i] and vpilecontent[i].tag == "Deck" then
            for _,o in pairs(vpilecontent[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k:find("Tactic:") then
                        tacticsfound = tacticsfound + 1
                        break
                    end
                end
            end
        elseif vpilecontent[i] and hasTag2(vpilecontent[i],"Tactic:",8) then
            tacticsfound = tacticsfound + 1
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = tacticsfound,
        label = "+" .. tacticsfound,
        tooltip = "Evil Deadpool gets +1 for each Mastermind Tactic in your victory pile.",
        f = 'updateMMDeadpool',
        f_owner = self})
end

function setupMM()
    updateMMDeadpool()
    function onObjectEnterZone(zone,object)
        if hasTag2(object,"Tactic:") then
            Wait.time(updateMMDeadpool,0.1)
        end
    end
    function onObjectLeaveZone(zone,object)
        if hasTag2(object,"Tactic:") then
            Wait.time(updateMMDeadpool,0.1)
        end
    end
    function onPlayerTurn(player,previous_player)
        updateMMDeadpool()
    end
end

function evildeadpool(params)
    evilDeadpoolStrike[params.color] = hasTag2(params.obj,"Cost:") or 0
    evilDeadpoolCounter = evilDeadpoolCounter + 1
    evilDeadpoolValue = math.min(evilDeadpoolValue,evilDeadpoolStrike[params.color])
    if evilDeadpoolCounter == #Player.getPlayers() then
        for i,p in pairs(evilDeadpoolStrike) do
            if p == evilDeadpoolValue then
                getObjectFromGUID(pushvillainsguid).Call('getWound',i)
            end
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    evilDeadpoolStrike = {}
    evilDeadpoolCounter = 0
    evilDeadpoolValue = 20
    broadcastToAll("Master Strike: Each player simultaneously discards a card. Whoever discards the lowest-costing card (or tied for lowest) gains a Wound.")
    for _,o in pairs(Player.getPlayers()) do
        
        if #o.getHandObjects() == 0 then
            evilDeadpoolCounter = evilDeadpoolCounter +1
        else
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                trigger_function = 'evildeadpool',
                args = "self",
                fsourceguid = self.guid})
        end
    end
    return strikesresolved
end
