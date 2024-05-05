function onLoad()
    loadGUIDs()
    
    --Turns.enable = true
end

function loadGUIDs()
    herocosts = {}
    for i=0,9 do
        table.insert(herocosts,0)
    end
    
    addguids = {
        ["Red"]="d833a0",
        ["Green"]="9ee1fd",
        ["Yellow"]="c3dfd7",
        ["Blue"]="03ad58",
        ["White"]="8a2ca3"
    }
    
    resourceguids = {
        ["Red"]="437bab",
        ["Green"]="be2dca",
        ["Yellow"]="e12656",
        ["Blue"]="2a97f0",
        ["White"]="e1c2bd"
    }
    
    shardguids = {
        ["Red"]="16ea02",
        ["Green"]="f06e6c",
        ["Yellow"]="5ecac6",
        ["Blue"]="188433",
        ["White"]="18da9e"
    }
    
    attackguids = {
        ["Red"]="789e5f",
        ["Green"]="d58330",
        ["Yellow"]="bdd497",
        ["Blue"]="e56ef6",
        ["White"]="3892b5"
    }
    
    playerBoards = {
        ["Red"]="8a35bd",
        ["Green"]="d7ee3e",
        ["Yellow"]="ed0d43",
        ["Blue"]="9d82f3",
        ["White"]="206c9c"
    }
    
    playguids = {
        ["Red"]="157bfe",
        ["Green"]="0818c2",
        ["Yellow"]="7149d2",
        ["Blue"]="2b36c3",
        ["White"]="558e75"
    }
    
    discardguids = {
        ["Red"]="1f6a15",
        ["Green"]="66abd3",
        ["Yellow"]="63d26e",
        ["Blue"]="2fd393",
        ["White"]="fee1de"
    }
    
    drawguids = {
        ["Red"]="c6ca07",
        ["Green"]="4e2f26",
        ["Yellow"]="c68179",
        ["Blue"]="862e3c",
        ["White"]="5d9596"
    }
    
    vpileguids = {
        ["Red"]="fac743",
        ["Green"]="a42b83",
        ["Yellow"]="7f3bcd",
        ["Blue"]="f6396a",
        ["White"]="7732c7"
    }
    
    handguids = {
        ["Red"]="1737b5",
        ["Green"]="c83e11",
        ["Yellow"]="627472",
        ["Blue"]="8c01fa",
        ["White"]="bd8b5c"
    }
    
    city_zones_guids = {
        "e6b0bc",
        "40b47d",
        "5a74e7",
        "07423f",
        "5bc848",
        "82ccd7"
    }
    
    local citynames = {"Sewers","Bank","Rooftops","Streets","Bridge"}
    cityguids = {}
    for i = 1,5 do
        cityguids[citynames[i]] = city_zones_guids[i+1]
    end
    
    hqguids = {
        "aabe45",
        "bf3815",
        "11b14c",
        "b8a776",
        "75241e"
    }
    
    hqscriptguids = {
        "3e049c",
        "745db7",
        "84bb5f",
        "7f27d3",
        "ddadbc"
    }
      
    topBoardGUIDs ={
        "1fa829",
        "bf7e87",
        "4c1868",
        "8656c3",
        "533311",
        "3d3ba7",
        "725c5d",
        "4e3b7e"
    }
    
    allTopBoardGUIDS = {
        "7f622a",
        "000e0c",
        "3e45a0",
        "705f8c",
        "1fa829",
        "bf7e87",
        "4c1868",
        "8656c3",
        "533311",
        "3d3ba7",
        "725c5d",
        "4e3b7e",
        "f394e1",
        "0559f8",
        "39e3d7",
        "6b1c18",
        "57df40"
    }
    
    setupGUID = "912967"
    pushvillainsguid = "f3c7e3"
      
    bystandersPileGUID = "0b48dd"
    woundsDeckGUID = "653663"
    sidekickDeckGUID = "d40734"
    officerDeckGUID = "aed7cd"
    
    schemePileGUID = "0716a4"
    mmPileGUID = "c7e1d5"
    strikePileGUID = "aff2e5"
    horrorPileGUID = "82f3dc"
    twistPileGUID = "c82082"
    villainPileGUID = "375566"
    hmPileGUID = "de8160"
    ambPileGUID = "cf8452"
    heroPileGUID = "16594d"
    
    heroDeckZoneGUID = "0cd6a9"
    villainDeckZoneGUID = "4bc134"
    schemeZoneGUID = "c39f60"
    mmZoneGUID = "a91fe7"
    strikeZoneGUID = "be6070"
    horrorZoneGUID = strikeZoneGUID
    twistZoneGUID = "4f53f9"
    officerZoneGUID = "791799"
    sidekickZoneGUID = "656a39"
    
    officerBuyGUID = "4d1383"
    sidekickBuyGUID = "9e8c5f"
    
    escape_zone_guid = "de2016"
    
    kopile_guid = "79d60b"
    
    shardspaceguid = "21e3f0"
    madamehydrazoneguid = "bd3ef1"
    recruitszoneguid = "d30aa1"
    bszoneguid = "2e5f2b"
    woundszoneguid = "12d37a"
    bindingszoneguid = "9509d4"
    
    shardGUID = "eff5ba"

    -- new with big playmat
    madamehydrazone2guid = "0b8a4a"
    newrecruitszone2guid = "00b962"

    city_topzones_guids = {
        "6d25f6",
        "a05f6c",
        "8822db",
        "8d6da2",
        "c0baa9"
    }
    
    --Local positions for each pile of cards
    pos_vp2 = {-4.75, 0.178, 0.222}
    pos_discard = {-0.957, 0.178, 0.222}
    pos_draw = {0.957, 0.178, 0.222}
    pos_add2 = {-2.871, 0.178, 0.222}
    
    --Remove any leftover mastermind lua code from a previous game
    getObjectFromGUID(strikeZoneGUID).setLuaScript("")
    getObjectFromGUID(strikeZoneGUID).reload()
end

function returnVar(var)
    return _G[var]
end

-- tables always refer to the same object in memory
-- this function allows to replicate them
function table.clone(params)
    if params.key then
        local new = {}
        for i,o in pairs(params.org) do
            new[i] = o
        end
        return new
    else
        return {table.unpack(params.org)}
    end
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    --this function returns cards, decks and shards in a city space (or the start zone)
    --returns a table of objects
    local zone = getObjectFromGUID(zoneGUID)
    if zone then
        decks = zone.getObjects()
    else
        return nil
    end
    local shardname = "Shard"
    local hopename = "Baby Hope Token"
    if shardinc == false then
        shardname = "notShardName"
        hopename = "notBaby Hope Token"
    end
    local result = {}
    if decks then
        for k, deck in pairs(decks) do
            if deck.tag == "Deck" or deck.tag == "Card" or deck.getName() == shardname or deck.getName() == hopename then
                if bsinc == nil or not deck.hasTag("Bystander") then
                    table.insert(result, deck)
                end
            end
        end
    end
    return result
end

function get_decks_and_cards_from_zone2(params)
    return get_decks_and_cards_from_zone(params.zoneGUID,params.shardinc,params.bsinc)
end

function hasTag2(params)
    local obj = params.obj
    local tag = params.tag
    local index = params.index
    if not obj or not tag then
        return nil
    end
    local tags = obj.getTags()
    if obj.hasTag("Split") then
        local altag1 = tag:sub(1,-2) .. 1 .. ":"
        local altag2 = tag:sub(1,-2) .. 2 .. ":"
        for i,t in pairs(tags) do
            if t:find(altag1) or t:find(altag2) then
                tags[i] = tag .. t:sub(tag:len()+2,-1)
            end
        end
    end
    local res = {}
    for _,o in pairs(tags) do
        if o:find(tag) then
            if index then
                table.insert(res,o:sub(index,-1))
            else 
                local num = tonumber(o:match("%d+"))
                if num then
                    table.insert(res,num)
                else
                    table.insert(res,o:sub(#tag+1,-1))
                end
            end
        end
    end
    if res[1] and res[2] then
        return res
    elseif res[1] then
        return res[1]
    else
        return nil
    end
end

function bump(params)
    if not params.y then
        params.y = 2
    end
    local pos = params.obj.getPosition()
    pos.y = pos.y + params.y
    params.obj.setPositionSmooth(pos)
end

function merge(params)
   for k,v in ipairs(params.t2) do
      table.insert(params.t1, v)
   end
   return params.t1
end

function removeButton(params)
    local butt = params.obj.getButtons()
    if butt then
        for i,o in pairs(butt) do
            if o.click_function == params.click_f then
                params.obj.removeButton(i-1)
                break
            end
        end
    end
end

function waitForMove(params)
    local waiting = function()
        local content = get_decks_and_cards_from_zone(params.zone)
        if content[1] and content[1].guid == params.card then
            return true
        else
            return false
        end
    end
    local resolving = function()
        if params.fsourceguid then
            getObjectFromGUID(params.fsourceguid).Call(params.triggerf)
        else
            params.triggerf()
        end
    end
    Wait.condition(resolving,waiting)
end

function hasTagD(params)
    local guids = {}
    local missingguids = 1
    for _,c in pairs(params.deck.getObjects()) do
        for _,tag in pairs(c.tags) do
            if tag == params.tag then
                if c.guid ~= "" then
                    table.insert(guids,c.guid)
                else
                    table.insert(guids,"noguid" .. missingguids)
                    missingguids = missingguids + 1
                end
                break
            end
        end
    end
    if guids[1] then
        return guids
    else
        return nil
    end
end

function findInPiles(params)
    local guid = params.guid
    local name = params.name
    local targetGUID = params.targetGUID
    
    local content = get_decks_and_cards_from_zone(guid)
    if not content[1] then
        return nil
    end
    local pos = getObjectFromGUID(targetGUID).getPosition()
    pos.y = pos.y + 2
    local count = 0
    if content[1] then
        for _,o in pairs(content) do
            if o.tag == "Deck" then
                count = count + getObjectFromGUID(setupGUID).Call('findInPile2',{
                    deckname = name,
                    pileGUID = o.guid,
                    destGUID = targetGUID,
                    n = true
                })
            elseif o.getName() == params.name then
                o.setPositionSmooth(pos)
                count = count + 1
            end
        end
    end
end