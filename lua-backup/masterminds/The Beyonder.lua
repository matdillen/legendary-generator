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

function updatePocketDimensions()
    for _,o in pairs(pocketdimensions) do
        local buttonfound = false
        for i,b in pairs(getObjectFromGUID(o).getButtons()) do
            if b.click_function == "updatePocketDimensions" then
                getObjectFromGUID(o).editButton({index=i-1,label=#pocketdimensions})
                buttonfound = true
                break
            end
        end
        if not buttonfound then
            getObjectFromGUID(o).createButton({click_function='updatePocketDimensions',
                function_owner=self,
                position={0,2,-2},
                label=#pocketdimensions,
                tooltip="To recruit a card from a Pocket Dimension, you must pay 1 for each Pocket Dimension in play.",
                font_size=500,
                font_color={1,0,0},
                color={1,1,1,0.85},
                width=650,height=450})
        end
    end
end

function pocketDimensionize(obj)
    table.insert(pocketdimensions,obj.guid)
    updatePocketDimensions()
    for _,o in pairs(hqguids) do
        for i,b in pairs(getObjectFromGUID(o).getButtons()) do
            if b.click_function == "pocketDimensionize" then
                getObjectFromGUID(o).removeButton(i-1)
                break
            end
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    if not pocketdimensions then
        pocketdimensions = {}
    end
    local beyond = 5
    if epicness then
        beyond = 6
    end
    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait=beyond,prefix="Cost:",what="Cost"})
    for _,o in pairs(players) do
        getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
    end
    for _,o in pairs(hqguids) do
        if #pocketdimensions ~= #hqguids then
            local already = false
            for _,k in pairs(pocketdimensions) do
                if k == o then
                    already = true
                    break
                end
            end
            if not already then
                getObjectFromGUID(o).createButton({click_function='pocketDimensionize',
                    function_owner=self,
                    position={0,2,0},
                    label="Pull",
                    tooltip="Pull this space into a Pocket Dimension",
                    font_size=350,
                    font_color={1,0,0},
                    color={0,0,0},
                    width=1000,height=600})
            end
        end
    end
    return strikesresolved
end
