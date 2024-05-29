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
    for _=1,2 do
        getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = strikeloc,
            face = false})
    end
    local pcolor = Turns.turn_color
    Wait.condition(
        function()
            getObjectFromGUID("[Arcade Tactic effect] Arcade loves a parade! An extra card is played from the villain deck!")
            getObjectFromGUID(pushvillainsguid).Call('playVillain')
        end,
        function()
            if Turns.turn_color == pcolor then
                return false
            else
                return true
            end
        end)
end