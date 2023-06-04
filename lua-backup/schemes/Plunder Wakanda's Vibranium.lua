function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs",
        "pos_discard"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    local guids3 = {
        "playerBoards"
        }
            
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
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

function resolveTwist(params) 
    local cards = params.cards
    
    cards[1].setName("Vibranium")
    cards[1].setTags({"Villainous Weapon","VP3"})
    
    local pos =getObjectFromGUID(escape_zone_guid).getPosition()
    for _,o in pairs(city) do
        local content = Global.Call('get_decks_and_cards_from_zone',o)
        if content[1] then
            for _,c in pairs(content) do
                if c.getName() == "Vibranium" then
                    c.setPosition(pos)
                end
            end
        end
    end
    broadcastToAll("incomplete twist scripting")
    return nil
end