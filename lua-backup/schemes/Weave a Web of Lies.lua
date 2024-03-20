function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids3 = {
        "vpileguids",
        "resourceguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end

    function onObjectEnterZone(zone,object)
        if object.hasTag("Bystander") then
            updateMMLiesRestriction()
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.hasTag("Bystander") then
            updateMMLiesRestriction()
        end
    end
    function onPlayerTurn(player,previous_player)
        updateMMLiesRestriction()
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

function updateMMLiesRestriction()
    local color = Turns.turn_color
    local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[color])
    local savior = 0
    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
        for _,k in pairs(vpilecontent[1].getObjects()) do
            for _,l in pairs(k.tags) do
                if l == "Bystander" then
                    savior = savior + 1
                    break
                end
            end
        end
    elseif vpilecontent[1] then
        if vpilecontent[1].hasTag("Bystander") then
            savior = 1
        end
    end
    local twists = getObjectFromGUID(pushvillainsguid).Call('returnVar',"twistsstacked")
    local checkvalue = 0
    if twists > savior then
        checkvalue = 1
    end
    local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
    local mmname = nil
    for i,o in pairs(mmLocations) do
        if o == mmZoneGUID then
            mmname = i
            break
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = checkvalue,
        label = "X",
        tooltip = "The mastermind can't be fought unless you have rescued a number of bystanders equal to the number of strikes stacked next to the scheme.",
        f = "mm"})
end

function buyBystander(params)
    if params.id == "yes" then
        local recruit = getObjectFromGUID(resourceguids[params.color]).Call('returnVal')
        if recruit < 1 then
            broadcastToColor("You don't have enough recruit to rescue a bystander!",params.color,params.color)
            fightEffect({color = params.color})
            return nil
        end
        getObjectFromGUID(resourceguids[params.color]).Call('addValue',-1)
        getObjectFromGUID(pushvillainsguid).Call('getBystander',params.color)
    end
end

function fightEffect(params)
    if not params.mm then
        getObjectFromGUID(pushvillainsguid).Call('offerChoice',{color = params.color,
            choices = {["yes"] = "Rescue for *",
                ["no"] = "Don't rescue"},
            resolve_function = "buyBystander",
            fsourceguid = self.guid})
        broadcastToColor("You fought a villain so the scheme lets you rescue a bystander for 1 Recruit.",params.color,params.color)
    end
end

function resolveTwist(params)
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    updateMMLiesRestriction()
    return nil
end