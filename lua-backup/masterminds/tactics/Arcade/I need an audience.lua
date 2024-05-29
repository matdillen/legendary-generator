function onLoad()
    local guids = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
    end
end

function tacticEffect(params)
    local zoneGUID = params.zoneGUID

    local mmLocations = Global.Call('table_clone',getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"))
    local strikeloc = nil
    for i,o in pairs(mmLocations) do
        if o == zoneGUID then
            strikeloc = getObjectFromGUID(mmZoneGUID).Call('getStrikeloc',i)
            break
        end
    end
    local city = Global.Call('table_clone',Global.Call('returnVar',"current_city"))
    local villaincount = 0
    for _,o in pairs(city) do
        local citycontent = getObjectFromGUID(o).getObjects()
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if obj.hasTag("Villain") then
                    villaincount = villaincount + 1
                end
            end
        end
    end
    if villaincount > 0 then
        for i=1,villaincount do
            getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = strikeloc,
                face = false})
        end
    end
end