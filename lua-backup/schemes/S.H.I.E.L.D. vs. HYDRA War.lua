function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID",
        "twistZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids3 = {
        "attackguids",
        "discardguids",
        "vpileguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end

    officersbeingfought = {}
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

function toggleButtons(off)
    local butt = self.getButtons()
    if off then
        if butt then
            for i,o in pairs(butt) do
                if o.click_function == "updatePowerSO" or o.click_function == "click_fight_double_agent" then
                    self.removeButton(i-1)
                end
            end
        end
    else
        local updatePowerSOfound = false
        local updateFightDO = false
        if butt then
            for _,o in pairs(butt) do
                if o.click_function == "updatePowerSO" then
                    updatePowerSOfound = true
                elseif o.click_function == "click_fight_double_agent" then
                    updateFightDO = true
                end
            end
        end
        if not updatePowerSOfound then
            self.createButton({click_function="updatePowerSO",
                function_owner=self,
                position={2,0,0},
                rotation={0,180,0},
                label="3",
                tooltip=".",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
        end
        if not updateFightDO then
            self.createButton({
                click_function="click_fight_double_agent", 
                function_owner=self,
                position={2,0,-0.75},
                rotation={0,180,0},
                label="Fight",
                tooltip="Fight for 3 to gain any of these Officers as heroes or send them Undercover to your Victory Pile.",
                color="Red",
                width=550,
                height=250,
                font_size = 70
           })
        end
    end
end

function updatePowerSO()
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
end

function click_fight_double_agent(obj,player_clicker_color)
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
    if not hulkdeck then
        return nil
    end
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < 3 then
        broadcastToColor("You don't have enough attack to defeat this double agent!",player_clicker_color,player_clicker_color)
        return nil
    end
    if officersbeingfought[player_clicker_color] then
        broadcastToColor("Resolve the choices for the previous officer first!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-3)
    getObjectFromGUID(pushvillainsguid).Call('offerCards',{
        color = player_clicker_color,
        pile = hulkdeck,
        resolve_function = "gainOrUndercover",
        toolt = "Fight this officer.",
        args = "self",
        fsourceguid = self.guid        
    })
end

function gainOrUndercover(object,player_clicker_color)
    object.locked = true
    officersbeingfought[player_clicker_color] = object.guid
    getObjectFromGUID(pushvillainsguid).Call('offerChoice',{
        color = player_clicker_color,
        choices = {["gain"] = "Gain",
            ["uc"] = "Undercover"},
        fsourceguid = self.guid,
        resolve_function = "gainOrUndercover2"
    })
end

function gainOrUndercover2(id,player_clicker_color)
    local object = getObjectFromGUID(officersbeingfought[player_clicker_color])
    officersbeingfought[player_clicker_color] = nil
    local pos = nil
    if id == "gain" then
        pos = getObjectFromGUID(discardguids[player_clicker_color]).getPosition()
    elseif id == "uc" then
        pos = getObjectFromGUID(vpileguids[player_clicker_color]).getPosition()
    end
    pos.y = pos.y + 2
    object.locked = false
    object.setPosition(pos)
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Hydra level: __/11.",
                ["zoneguid"] = escape_zone_guid}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            for _,o in pairs(escaped[1].getObjects()) do
                if o.getName():find("HYDRA") or o.getName():find("SHIELD") or o.getName():find("S.H.I.E.L.D.") then
                    counter = counter + 1
                else
                    for _,t in pairs(o.tags) do
                        if t == "Starter" or t == "Team:SHIELD" or t == "Team:SHIELD" then
                            counter = counter + 1
                            break
                        end
                    end
                end
            end
        elseif escaped[1] then
            if escaped[1].hasTag("Starter") or escaped[1].hasTag("Team:SHIELD") or escaped[1].hasTag("Team:SHIELD") then
                counter = counter + 1
            elseif escaped[1].getName():find("HYDRA") or escaped[1].getName():find("SHIELD") or escaped[1].getName():find("S.H.I.E.L.D.") then
                counter = counter + 1
            end
        end
        return counter
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local officerdeck = getObjectFromGUID(officerDeckGUID)
    local twistpilecontent = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    toggleButtons()
    if twistpilecontent[1] then
        broadcastToAll("Scheme Twist: An Officer escaped! HYDRA level increased!")
        if twistpilecontent[1].tag == "Deck" then
            local bottomRest = function(obj)
                local twistpilecontent = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
                twistpilecontent[1].flip()
                twistpilecontent[1].setPositionSmooth(officerdeck.getPosition())
            end
            twistpilecontent[1].takeObject({position=getObjectFromGUID(escape_zone_guid).getPosition(),
                callback_function = bottomRest})
        else
            twistpilecontent[1].setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
        end
    end
    for i = 1,#Player.getPlayers() do
        officerdeck.takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
            flip=true})
    end
    return twistsresolved
end