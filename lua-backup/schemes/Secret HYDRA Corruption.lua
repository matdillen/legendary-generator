function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "officerDeckGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function gainOfficer(params)
    local officers = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
    local pos = getObjectFromGUID(discardguids[params.id]).getPosition()
    pos.y = pos.y + 2
    if officers and officers.tag == "Deck" then
        officers.takeObject({position = pos,
            flip = false})
    elseif officers then
        officers.setPosition(pos)
    end
end

function buyOfficer(obj,player_clicker_color)
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    if recruit < 3 then
        broadcastToColor("You don't have enough recruit to save this HYDRA sympathizer!",player_clicker_color,player_clicker_color)
        return nil
    else
        getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-3)
        getObjectFromGUID(pushvillainsguid).Call('offerChoice',{color = player_clicker_color,
            choices = "players",
            fsourceguid = self.guid,
            resolve_function = 'gainOfficer'})
    end
end

function fightOfficer(obj,player_clicker_color)
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < 3 then
        broadcastToColor("You don't have enough recruit to save this HYDRA sympathizer!",player_clicker_color,player_clicker_color)
        return nil
    else
        getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-3)
        broadcastToColor("You fought a traitor! KO one of your heroes!",player_clicker_color,player_clicker_color)
        local pos = officerdeck.getPosition()
        pos.y = pos.y +1
        obj.setPosition(pos)
        Wait.time(function() officerdeck.randomize() end,1)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local twistpile = getObjectFromGUID(twistZoneGUID)
    if twistsresolved == 1 then
        officerdeck = getObjectFromGUID(officerDeckGUID)
        twistpile.createButton({click_function=buyOfficer,
            function_owner=self,
            position={0,0,0},
            rotation={0,180,0},
            label="3",
            tooltip="Pay 3 Recruit to have any player gain one of these Officers.",
            font_size=350,
            font_color="Yellow",
            color={0,0,0,0.75},
            width=250,height=250})
    end
    if self.is_face_down == false then
        self.flip()
        twistpile.editButton({tooltip = "Fight for 3 to return any of these officers to the Officer deck and KO one of your heroes.",
            font_color = "Red",
            click_function = fightOfficer})
    else
        self.flip()
        twistpile.editButton({tooltip = "Pay 3 Recruit to have any player gain one of these Officers.",
            font_color = "Yellow",
            click_function = buyOfficer})
    end
    local pos = twistpile.getPosition()
    pos.y = pos.y + 1
    for i = 1,twistsresolved do
        if officerdeck.getQuantity() > 1 then
            officerdeck.takeObject({position=pos,
                flip=true,
                smooth=true})
            if officerdeck.remainder then
                officerdeck = officerdeck.remainder
            end
            pos.y = pos.y + 0.1
        else
            officerdeck.flip()
            officerdeck.setPositionSmooth(pos)
            officerdeck = nil
            break
        end
    end
    if not officerdeck then
        broadcastToAll("Officer deck ran out. Evil wins!",{1,0,0})
    end
    return twistsresolved
end