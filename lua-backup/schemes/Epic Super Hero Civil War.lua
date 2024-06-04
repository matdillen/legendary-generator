function onLoad()   
    twistsstacked = 0
    
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID"
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

function click_ko(obj)
    local hero = obj.Call('getHeroUp')
    if hero then
        getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
        obj.Call('click_draw_hero')
        twistsstacked = twistsstacked - 1
        if twistsstacked == 0 then
            for _,o in pairs(hqguids) do
                local hqZone = getObjectFromGUID(o)
                local index = 2
                for i,b in pairs(hqZone.getButtons()) do
                    if b.click_function == "click_ko" then
                        index = i
                        break
                    end
                end
                hqZone.removeButton(index-1)
            end
            getObjectFromGUID(heroDeckZoneGUID).clearButtons()
        else
            getObjectFromGUID(heroDeckZoneGUID).editButton({label = "(" .. twistsstacked .. ")"})
        end
    end
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Hero deck count: __.",
                ["zoneguid"] = heroDeckZoneGUID}
    else
        local vildeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1]
        if vildeck then
            return math.abs(vildeck.getQuantity())
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local cards = params.cards
    
    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('returnVar',"twistsstacked")
    broadcastToAll("Scheme Twist: KO " .. twistsstacked .. " heroes from the HQ, one at a time.")
    for _,o in pairs(hqguids) do
        getObjectFromGUID(o).createButton({click_function="click_ko",
            function_owner=self,
            position={0,3,0},
            label="KO",
            tooltip="KO this hero.",
            color={0,0,0,1}, 
            width=1500, height=750,
            font_size = 250,
            font_color = "Red"})
    end
    getObjectFromGUID(heroDeckZoneGUID).createButton({click_function="updatePower",
            function_owner = getObjectFromGUID(pushvillainsguid),
            position={0,3,0},
            rotation={0,180,0},
            label="(" .. twistsstacked .. ")",
            tooltip="Heroes to KO.",
            width=0,
            font_size = 250,
            font_color = "Red"})
    return nil
end