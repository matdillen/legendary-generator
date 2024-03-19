function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "cityguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function setupSpecial(params)
    for i,guid in pairs(cityguids) do
        getObjectFromGUID(guid).editButton({index = 0,
            label = "Scan",
            click_function = 'scan_villain',
            tooltip = "Scan the face down card in this city space for 1 attack."})
    end 
end