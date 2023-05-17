function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function grandmasterContest(params)
    for i,o in pairs(params.obj) do
        if i == "Evil" and o == true then
            local shardn = 1
            if epicness then
                shardn = 2
                broadcastToAll("Master Strike: Evil won, so the mastermind gains two shards!")
            else
                broadcastToAll("Master Strike: Evil won, so the mastermind gains a shard!")
            end
            getObjectFromGUID(pushvillainsguid).Call('gainShard2',{zoneGUID = mmloc,
                n = shardn})
        elseif not o and i ~= "Evil" then
            getObjectFromGUID(pushvillainsguid).Call('getWound',i)
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    epicness = params.epicness
    mmloc = params.mmloc

    local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)
    local color = nil
    local cost = 0
    if not herodeck[1] then
        broadcastToAll("No hero deck found")
        return nil
    elseif herodeck[1].tag == "Deck" then
        for _,o in pairs(herodeck[1].getObjects()[1].tags) do
            if o:find("HC:") then
                if color then
                    color = {color}
                    table.insert(color,(o:gsub("HC:","")))
                else
                    color = o:gsub("HC:","")
                end
            end
            if o:find("HC1:") then
                if color then
                    color = {color}
                    table.insert(color,(o:gsub("HC1:","")))
                else
                    color = o:gsub("HC1:","")
                end
            end
            if o:find("HC2:") then
                if color then
                    color = {color}
                    table.insert(color,(o:gsub("HC2:","")))
                else
                    color = o:gsub("HC2:","")
                end
            end
            if o:find("Cost:") then
                cost = o:gsub("Cost:","")
            end
        end
        if color[1] then
            broadcastToAll("Master Strike: " .. color[1] .. " and " .. color[2] .. " hero revealed from the hero deck with cost " .. cost .. ".")
        else
            broadcastToAll("Master Strike: " .. color .. " hero revealed from the hero deck with cost " .. cost .. ".")
        end
    else
        color = hasTag2(herodeck[1],"HC:")
        broadcastToAll("Master Strike: " .. color .. " hero revealed from the hero deck with cost " .. hasTag2(herodeck[1],"Cost:") .. ".")
    end
    getObjectFromGUID(pushvillainsguid).Call('contestOfChampions',{color = color,
        winf = 'grandmasterContest',
        epicness = epicness,
        fsourceguid = self.guid})
    return strikesresolved
end
