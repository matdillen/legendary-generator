function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function setupSpecial()
    setNotes(getNotes() .. "\r\n\r\n[9D02F9][b]Shards in use:[/b][-] 0")
    shards = {}
    shardlimit = 30
end

function updateShards(guid)
    if guid then
        local newshard = true
        for i,o in pairs(shards) do
            if o == guid then
                newshard = false
                break
            end
        end
        if newshard == true then
            table.insert(shards,guid)
        end
    end
    local shardcount = 0
    for _,o in pairs(shards) do
        local shard = getObjectFromGUID(o)
        if shard then
            shardcount = shardcount + shard.Call('returnVal')
        end
    end
    setNotes(getNotes():gsub("Shards in use:%[/b%]%[%-%] %d+","Shards in use:[/b][-] " .. shardcount))
    return shardcount
end

function returnShardLimit()
    if shardlimit then
        local limit = shardlimit - updateShards()
        return limit
    else
        return nil
    end
end

function resolveTwist(params)
    local cards = params.cards
    
    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    getObjectFromGUID(pushvillainsguid).Call('gainShard2',{zoneGUID = mmZoneGUID,
        n = twistsstacked})
    Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('updatePower') end,0.2)
    broadcastToAll("Scheme Twist: The Mastermind gains " .. twistsstacked .. " shards.")
    return nil
end