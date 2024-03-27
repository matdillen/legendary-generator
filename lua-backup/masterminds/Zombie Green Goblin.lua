function onLoad()
    mmname = "Zombie Green Goblin"
    
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMZombieGoblin()
    local kopilecontent = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
    local nongrey = 0
    if kopilecontent[1] and kopilecontent[1].tag == "Deck" then
        for _,k in pairs(kopilecontent[1].getObjects()) do
            for _,l in pairs(k.tags) do
                if l:find("Cost:") and tonumber((l:gsub("Cost:",""))) > 6 then
                    nongrey = nongrey + 1
                    break
                end
            end
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = nongrey,
        label = "+" .. nongrey,
        tooltip = "Zombie Green Goblin gets +1 for each hero that costs 7 or more in the KO pile.",
        f = 'updateMMZombieGoblin',
        id = "goblintragedy",
        f_owner = self})
end

function setupMM()
    updateMMZombieGoblin()
    function onObjectEnterZone(zone,object)
        if zone.guid == kopile_guid then
            updateMMZombieGoblin()
        end
    end
    function onObjectLeaveZone(zone,object)
        if zone.guid == kopile_guid then
            updateMMZombieGoblin()
        end
    end
end

function resolveStrike(params)    
    local strikesresolved = params.strikesresolved
    
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and hasTag2(hero,"Cost:") > 6  then
            hero.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
            getObjectFromGUID(o).Call('click_draw_hero')
        end
    end
    function goblinDiscards()
        local kopile = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        local todiscard = 0
        if kopile[1] and kopile[2] then
            broadcastToAll("Please merge the KO pile into a single stack.")
            return nil
        end
        if kopile[1] and kopile[1].tag == "Deck" then
            for _,o in pairs(kopile[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k:find("Cost:") and tonumber(k:match("%d+")) > 6 then
                        todiscard = todiscard + 1
                        break
                    end
                end
            end
        elseif kopile[1] then
            if hasTag2(kopile[1],"Cost:") and hasTag2(kopile[1],"Cost:") > 6 then
                todiscard = todiscard + 1
            end
        end
        broadcastToAll("Master Strike! Each player discards " .. todiscard .. " cards.")
        for _,o in pairs(Player.getPlayers()) do
            promptDiscard({color = o.color,
                n = todiscard})
        end
    end
    Wait.time(goblinDiscards,2)
    return strikesresolved
end