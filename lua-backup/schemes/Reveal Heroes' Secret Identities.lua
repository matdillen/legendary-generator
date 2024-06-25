unmasked = {}

function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
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

function checkUnmasked()
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            local isUnmasked = false
            for _,k in pairs(unmasked) do
                if hero.getName() == k then
                    updateUnmasked(o,true)
                    isUnmasked = true
                    break
                end
            end
            if isUnmasked == false then
                updateUnmasked(o,false)
            end
        end
    end
end

function updateUnmasked(guid,isUnmasked)
    local butt = getObjectFromGUID(guid).getButtons()
    for i,o in pairs(butt) do
        if o.label == "+1*" then
            if isUnmasked == false then
                getObjectFromGUID(guid).removeButton(i-1)
            end
            return nil
        end
    end
    if isUnmasked == true then
        getObjectFromGUID(guid).createButton({click_function='updatePower',
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,2,-2},
            label="+1*",
            tooltip="All cards with Unmasked Hero Names cost +1 to recruit.",
            font_size=500,
            font_color="Yellow",
            color={1,1,1,0.85},
            width=0})
    end
end

function onObjectEnterZone(zone,object)
    Wait.time(checkUnmasked,1)
end

function onObjectLeaveZone(zone,object)
    Wait.time(checkUnmasked,1)
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Unmasked heroes: __/5"}
    else
        return #unmasked
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        local isUnmasked = false
        if hero then
            for _,p in pairs(unmasked) do
                if hero.getName() == p then
                    isUnmasked = true
                    break
                end
            end
            if not isUnmasked then
                _G["unmaskHero" .. hero.guid] = function(obj)
                    local hero = obj.Call('getHeroUp')
                    if not hero then
                        return nil
                    else
                        for _,k in pairs(hqguids) do
                            local butt = getObjectFromGUID(k).getButtons()
                            for i,b in pairs(butt) do
                                if b.click_function:find("unmaskHero") then
                                    getObjectFromGUID(k).removeButton(i-1)
                                end
                            end
                        end
                        table.insert(unmasked,hero.getName())
                        hero.setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
                        obj.Call('click_draw_hero')
                    end
                end
                getObjectFromGUID(o).createButton({click_function="unmaskHero" .. hero.guid,
                    function_owner=self,
                    position={0,2,0},
                    label="Unmask",
                    tooltip="Unmask this hero",
                    font_size=250,
                    font_color="Black",
                    color={1,1,1},
                    width=750,height=450})
            end
        end
    end
    return twistsresolved
end