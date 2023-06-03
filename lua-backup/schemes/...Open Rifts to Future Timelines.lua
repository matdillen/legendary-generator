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
    local content = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
    if content[1] then
        content[1].randomize()
    end
end

function revealScheme()
    local villainpile = getObjectFromGUID(villainPileGUID)
    villainpile.randomize()
    villainpile.takeObject({position = getObjectFromGUID(villainDeckZoneGUID).getPosition(),
        flip = true,
        callback_function = 'juggle'})
    local manipulations = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])[1]
    if manipulations then
        manipulations_stacked = math.abs(manipulations.getQuantity())
    end
end

function pushHench(obj,player_clicker_color)
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
    Wait.condition(vilgo,vilisthere)
end

function resolveTwist(params) 
    local cards = params.cards

    manipulations_stacked = manipulations_stacked + 1
    cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
    
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck and vildeck.tag == "Deck" then
        local vildeckc = vildeck.getObjects()
        local hench = {}
        local vils = {}
        local vp = 0
        for i = 1,manipulations_stacked do
            if vildeckc[i].hasTag("Henchmen") then
                table.insert(hench,vildeckc[i].guid)
            end
            if vildeckc[i].hasTag("Villain") and hasTag2(vildeckc[i],"vp") then
                if hasTag2(vildeckc[i],"vp") == vp then
                    table.insert(vils,vildeckc[i].guid)
                elseif hasTag2(vildeckc[i],"vp") > vp then
                    vils = {vildeckc[i].guid}
                    vp = hasTag2(vildeckc[i],"vp")
                end
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
                callback_function = 'pushHench'})
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
                    callback_function = 'pushVil'})
            end
        end
        Wait.condition(villainpush,vildelay)
    end
    return nil
end