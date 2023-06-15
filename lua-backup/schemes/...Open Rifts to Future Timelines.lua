function onLoad()   
    manipulations_stacked = 0
    
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "villainDeckZoneGUID",
        "villainPileGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs",
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function juggle(obj)
    obj.flip()
    
    Wait.time(function()
        local content = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
        content[1].randomize()
        end,1)
end

function revealScheme()
    local villainpile = getObjectFromGUID(villainPileGUID)
    villainpile.randomize()
    villainpile.takeObject({position = getObjectFromGUID(villainDeckZoneGUID).getPosition(),
        smooth = false,
        callback_function = juggle})
    local manipulations = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])[1]
    if manipulations then
        manipulations_stacked = math.abs(manipulations.getQuantity())
    end
end

function pushHench(obj,player_clicker_color)
    for i,o in pairs(vils) do
        if o == obj.guid then
            table.remove(vils,i)
        end
    end
    local henchisthere = function()
        local content = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
        if content[1] and content[1].guid == obj.guid then
            return true
        else
            return false
        end
    end
    local henchgo = function()
        getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
        henchhasgone = true
    end
    Wait.condition(henchgo,henchisthere)
end

function pushVil(obj,player_clicker_color)
    local vilisthere = function()
        local content = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])
        if content[1] and content[1].guid == obj.guid then
            return true
        else
            return false
        end
    end
    local vilgo = function()
        getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    end
    Wait.time(function() Wait.condition(vilgo,vilisthere) end,0.5)
end

function resolveTwist(params) 
    local cards = params.cards

    manipulations_stacked = manipulations_stacked + 1
    cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
    
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck and vildeck.tag == "Deck" then
        local vildeckc = vildeck.getObjects()
        hench = {}
        vils = {}
        local vp = 0
        for i = 1,manipulations_stacked do
            local isvillain = false
            local currentvp = nil
            for _,t in pairs(vildeckc[i].tags) do
                if t == "Henchmen" then
                    table.insert(hench,vildeckc[i].guid)
                end
                if t == "Villain" then 
                    isvillain = true
                end
                if t:find("VP") then
                    local vpn = tonumber(t:match("%d+"))
                    if vpn >= vp then
                        currentvp = vpn
                    end
                end
            end
            if isvillain and currentvp then
                table.insert(vils,vildeckc[i].guid)
                vp = currentvp
            end
        end
        if #hench > 1 then
            henchhasgone = false
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = Turns.turn_color,
                pile = vildeck,
                guids = hench,
                resolve_function = 'pushHench',
                fsourceguid = self.guid,
                label = "Push",
                tooltip = "Push this henchmen villain into the city.",
                flip = true,
                args = "self"})
        elseif hench[1] then
            henchhasgone = false
            vildeck.takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                flip = true,
                smooth = true,
                guid = hench[1],
                callback_function = pushHench})
        else
            henchhasgone = true
        end
        local vildelay = function()
            return henchhasgone
        end
        local villainpush = function()
            if #vils > 1 then
                getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = Turns.turn_color,
                    pile = vildeck,
                    guids = vils,
                    resolve_function = 'pushVil',
                    fsourceguid = self.guid,
                    label = "Push",
                    tooltip = "Push this villain into the city.",
                    flip = true,
                    args = "self"})
            elseif vils[1] then
                vildeck.takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    flip = true,
                    smooth = true,
                    guid = vils[1],
                    callback_function = pushVil})
            end
        end
        Wait.condition(villainpush,vildelay)
    elseif vildeck and vildeck.hasTag("Villain") then
        getObjectFromGUID(pushvillainsguid).Call('click_draw_villain')
        pushVil(vildeck)
    end
    return nil
end