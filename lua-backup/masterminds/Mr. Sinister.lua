function onLoad()
    mmname = "Mr. Sinister"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local strikeloc = params.strikeloc

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Red")
    getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = strikeloc,
        posabsolute = false})
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