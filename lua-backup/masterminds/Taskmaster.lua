function onLoad()
    mmname = "Taskmaster"
    strikesstacked = 0
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function updateMMTaskmaster()
    local bs = Global.Call('get_decks_and_cards_from_zone',self.guid)
    local boost = 0
    if bs[1] then
        boost = math.abs(bs[1].getQuantity())
    end
    local boostlab = 1
    if epicness then
        boost = boost*2
        boostlab = 2
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = boost,
        label = "+" .. boost,
        tooltip = mmname .. " gets +" .. boostlab .. " for each Master Strike stacked next to him.",
        f = 'updateMMTaskmaster',
        id = "taskmastrstriker",
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    updateMMTaskmaster()
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMTaskmaster,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMTaskmaster,0.1)
    end
end

function resolveStrike(params)
    local city = params.city
    local cards = params.cards

    if cards[1] then
        strikesstacked = strikesstacked + 1
        cards[1].setPositionSmooth(self.getPosition())
    end
    local henchfound = false
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if obj.hasTag("Henchmen") then
                    getObjectFromGUID(pushvillainsguid).Call('dealWounds')
                    henchfound = true
                    break
                end
            end
            if henchfound == true then
                break
            end
        end
    end
    return nil
end