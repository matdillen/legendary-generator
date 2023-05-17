function onLoad()
    local guids1 = {
        "pushvillainsguid"
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    local kanglabel = "⌛+2"
    if epicness == true then
        kanglabel = "⌛+3"
    end
    local current_city = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
    if strikesresolved == 1 then
        timeIncursions = {current_city[2]}
        getObjectFromGUID(timeIncursions[1]).createButton({click_function='updatePower',
                    function_owner=getObjectFromGUID(pushvillainsguid),
                    position={0,0,0.5},
                    rotation={0,180,0},
                    label=kanglabel,
                    tooltip="This city space is under a Time Incursion.",
                    font_size=150,
                    font_color="Blue",
                    color={0,0,0,0.75},
                    width=250,height=250})
    else
        for i=2,#current_city do
            local guidfound = false
            for _,o in pairs(timeIncursions) do
                if o == current_city[i] then
                    guidfound = true
                    break
                end
            end
            if guidfound == false then
                table.insert(timeIncursions,current_city[i])
                getObjectFromGUID(current_city[i]).createButton({click_function='updatePower',
                    function_owner=getObjectFromGUID(pushvillainsguid),
                    position={0,0,0.5},
                    rotation={0,180,0},
                    label=kanglabel,
                    tooltip="This city space is under a Time Incursion.",
                    font_size=150,
                    font_color="Blue",
                    color={0,0,0,0.75},
                    width=250,height=250})
                break
            end
            if i == #current_city then
                broadcastToAll("Master Strike: But the whole city is under time incursions already!")
            end
        end
    end
    if epicness == true then
        for _,o in pairs(timeIncursions) do
            local content = Global.Call('get_decks_and_cards_from_zone',o)
            if content[1] then
                for _,p in pairs(content) do
                    if p.hasTag("Villain") then
                        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
                        broadcastToAll("Master Strike: There were villains under time incursion so Epic Kang wounds everyone!")
                        return strikesresolved
                    end
                end
            end
        end
    end
    return strikesresolved
end
