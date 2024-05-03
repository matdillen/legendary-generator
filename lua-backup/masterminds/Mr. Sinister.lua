function onLoad()
    mmname = "Mr. Sinister"
    
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

function updateMMMrSinister()
    local bs = Global.Call('get_decks_and_cards_from_zone',self.guid)
    local boost = 0
    if bs[1] then
        boost = math.abs(bs[1].getQuantity())
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = boost,
        label = "+" .. boost,
        tooltip = "Mr. Sinister gets +1 for each Bystander he has.",
        f = 'updateMMMrSinister',
        id = "sinistersbs",
        f_owner = self})
end

function setupMM()
    function onObjectEnterZone(zone,object)
        if object.hasTag("Bystander") then
            Wait.time(updateMMMrSinister,0.1)
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.hasTag("Bystander") then
            Wait.time(updateMMMrSinister,0.1)
        end
    end
end

function fightEffect(params)
    if params.mm and params.obj.guid == self.guid then
        local bs = Global.Call('get_decks_and_cards_from_zone',self.guid)[1]
        if bs then
            local pos = getObjectFromGUID(vpileguids[params.color]).getPosition()
            pos.y = pos.y + 2
            bs.setPositionSmooth(pos)
            broadcastToColor("You saved " .. math.abs(bs.getQuantity()) .. " bystander(s) captured by the mastermind!", params.color, params.color)
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local strikeloc = params.strikeloc

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Red")
    local pos = getObjectFromGUID(strikeloc).getPosition()
    getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{pos = pos})
    --sadly, zombie mr sinister has no strikeloc...
    local bs = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    local sinisterbs = 1
    if bs[1] then
        sinisterbs = math.abs(bs[1].getQuantity()) + 1
    end
    for _,o in pairs(players) do
        local hand = o.getHandObjects()
        if #hand == 6 then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                n = sinisterbs})
            broadcastToColor("Master Strike: Discard " .. sinisterbs .. " cards.",o.color,o.color)
        end
    end
    return strikesresolved
end