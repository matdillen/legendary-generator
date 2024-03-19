function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "sidekickZoneGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "resourceguids",
        "attackguids",
        "discardguids"
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

function setupSpecial()
    local mmZone = getObjectFromGUID(mmZoneGUID)
    mmZone.Call('lockTopZone',topBoardGUIDs[1])
    mmZone.Call('lockTopZone',topBoardGUIDs[2])
end

function recruitSave(obj,player_clicker_color)
    local kidnapped = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
    if not kidnapped then
        return nil
    else
        local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
        if recruit < 3 then
            broadcastToColor("You don't have enough Recruit to gain this sidekick!",player_clicker_color,player_clicker_color)
            return nil
        else
            getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-3)
            local pos = getObjectFromGUID(discardguids[player_clicker_color]).getPosition()
            pos.y = pos.y + 2
            if kidnapped.tag == "Card" then
                kidnapped.flip()
                kidnapped.setPosition(pos)
            else
                kidnapped.takeObject({position = pos,
                    flip = true,
                    smooth = false})
            end
        end
    end
end

function attackSave(obj,player_clicker_color)
    local kidnapped = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
    if not kidnapped then
        return nil
    else
        local recruit = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
        if recruit < 3 then
            broadcastToColor("You don't have enough Attack to gain this sidekick!",player_clicker_color,player_clicker_color)
            return nil
        else
            getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-3)
            local pos = getObjectFromGUID(discardguids[player_clicker_color]).getPosition()
            pos.y = pos.y + 2
            if kidnapped.tag == "Card" then
                kidnapped.flip()
                kidnapped.setPosition(pos)
            else
                kidnapped.takeObject({position = pos,
                    flip = true,
                    smooth = false})
            end
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    local kidnappedmutants = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    local sidekickdeck = Global.Call('get_decks_and_cards_from_zone',sidekickZoneGUID)[1]
    local twistzone = getObjectFromGUID(twistZoneGUID)
    if twistsresolved < 7 then
        if not self.getButtons() then
            twistzone.createButton({click_function='recruitSave',
                function_owner=self,
                position={0,0.1,0.5},
                rotation={0,180,0},
                scale = {1,1,0.5},
                label="3",
                tooltip="Spend 3 Recruit to gain this sidekick.",
                font_size=300,
                font_color={0,0,0},
                color="Yellow",
                width=500,height=300})
            twistzone.createButton({click_function='attackSave',
                function_owner=self,
                position={0,0.1,-0.5},
                rotation={0,180,0},
                scale = {1,1,0.5},
                label="3",
                tooltip="Spend 3 Attack to gain this sidekick.",
                font_size=300,
                font_color={0,0,0},
                color="Red",
                width=500,height=300})
        end
        for i = 1,2 do
            sidekickdeck.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                flip = false,
                smooth = true})
        end
        if kidnappedmutants[1] then
            Global.Call('bump',{obj = sidekickdeck})
            kidnappedmutants[1].setPositionSmooth(getObjectFromGUID(sidekickZoneGUID).getPosition())
            cards[1].setName("Drained Power")
            cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
            return nil
        end
    elseif twistsresolved == 7 then
        if kidnappedmutants[1] then
            Global.Call('bump',{obj = sidekickdeck})
            kidnappedmutants[1].setPositionSmooth(getObjectFromGUID(sidekickZoneGUID).getPosition())
        end
        getObjectFromGUID(pushvillainsguid).Call('unveilScheme',self)
        return nil
    end
    return twistsresolved
end