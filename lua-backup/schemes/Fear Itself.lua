function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function purgeHero(params) 
    local obj = params.obj
    local index = params.index
    
    getObjectFromGUID(pushvillainsguid).Call('koCard',obj)
    local ishq = false
    local hqguids_ori = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"hqguids_ori"))
    for i,o in pairs(hqguids_ori) do
        if o == hqguids[index] then
            ishq = i
        end
    end
    if ishq ~= false and #hqguids > 5 then
        local removezone = table.remove(hqguids)
        local pos = getObjectFromGUID(hqguids_ori[ishq]).getPosition()
        pos.y = pos.y + 2
        getObjectFromGUID(removezone).Call('getHeroUp').setPosition(pos)
        getObjectFromGUID(removezone).destruct()
    else
        getObjectFromGUID(hqguids[index]).destruct()
        table.remove(hqguids,index)
    end
    getObjectFromGUID(pushvillainsguid).Call('updateCity',{newcity = hqguids,name = "hqguids"})
    getObjectFromGUID(mmZoneGUID).Call('updateHQ',pushvillainsguid)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    if not hqguids then
        hqguids = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar','hqguids'))
    end
    if twistsresolved < 8 then
        local candidate = {}
        for i,o in ipairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                table.insert(candidate,hero)
            else
                printToAll("Missing hero in HQ!!")
                return nil
            end
        end
        broadcastToAll("Scheme Twist: KO a hero from the HQ and the fear level goes down by 1, removing one HQ space")
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = candidate,
            pos = getObjectFromGUID(kopile_guid).getPosition(),
            label = "KO",
            tooltip = "KO this hero.",
            trigger_function = 'purgeHero',
            args = "self",
            fsourceguid = self.guid})
    else
        broadcastToAll("Scheme Twist: The Fear level is 0. Evil wins!")
    end
    return twistsresolved
end