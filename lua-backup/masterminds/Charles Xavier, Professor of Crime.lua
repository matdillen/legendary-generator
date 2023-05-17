function onLoad()
    local guids1 = {
        "pushvillainsguid"
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

function noWitness(obj)
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        local pos = hero.getPosition()
        pos.y = pos.y + 3
        pos.z = pos.z - 2
        if hero.guid ~= obj.guid then
            getObjectFromGUID(pushvillainsguid).Call('addBystanders',{cityspace = o,
                face = false,
                pos = pos})
        end
        hero.clearButtons()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    broadcastToAll("Master Strike: Choose a HQ zone to which NO hidden witness will be added!")
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then
            broadcastToAll("Missing hero. Script failed.")
            return nil
        end
        hero.createButton({click_function="noWitness",
            function_owner=self,
            position={0,22,0},
            label="Exclude",
            tooltip="Don't put a hidden witness here.",
            font_size=250,
            font_color="Black",
            color={1,1,1},
            width=750,height=450})
    end
    return strikesresolved
end
