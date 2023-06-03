function onLoad()
    mmname = "Mole Man"
    
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMMoleMan()
    local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
    local bscount = 0
    if escaped[1] and escaped[1].tag == "Deck" then
        for _,o in pairs(escaped[1].getObjects()) do
            for _,k in pairs(o.tags) do
                if k == "Group:Subterranea" then
                    bscount = bscount + 1
                    break
                end
            end
        end
    elseif escaped[1] and escaped[1].hasTag("Group:Subterranea") then
        bscount = bscount + 1
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = bscount,
        label = "+" .. bscount,
        tooltip = "Mole Man gets +1 for each Subterranea Villain that has escaped.",
        f = 'updateMMMoleMan',
        f_owner = self})
end

function setupMM()
    updateMMMoleMan()
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMMoleMan,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMMoleMan,0.1)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local city = params.city

    local subescaped = false
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,p in pairs(citycontent) do
                if hasTag2(p,"Group:",7) and hasTag2(p,"Group:",7) == "Subterranea" then
                    subescaped = true
                    getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = citycontent,
                        targetZone = getObjectFromGUID(escape_zone_guid),
                        enterscity = 0})
                    break
                end
            end
        end
    end
    if subescaped == true then
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    end
    broadcastToAll("Master Strike: All Subterranea Villains in the city escape. If any Villains escaped this way, each player gains a Wound.")
    return strikesresolved
end