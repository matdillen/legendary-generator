function onLoad()
    mmname = "Baron Heinrich Zemo"
    
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "mmZoneGUID",
        "bystandersPileGUID",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "vpileguids",
        "resourceguids",
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

function updateMMBaronHein()
    local color = Turns.turn_color
    local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[color])
    local savior = 0
    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
        for _,k in pairs(vpilecontent[1].getObjects()) do
            for _,l in pairs(k.tags) do
                if l == "Bystander" then
                    savior = savior + 1
                    break
                end
            end
            if savior > 2 then
                break
            end
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = math.max(3-savior,0),
        label = "+9",
        tooltip = "The Baron gets +9 as long as you're not a Savior of at least 3 bystanders.",
        f = 'updateMMBaronHein',
        f_owner = self})
end

function setupMM()
    updateMMBaronHein()
    function onObjectEnterZone(zone,object)
        if object.hasTag("Bystander") then
            updateMMBaronHein()
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.hasTag("Bystander") then
            updateMMBaronHein()
        end
    end
    function onPlayerTurn(player,previous_player)
        updateMMBaronHein()
    end
end

function buyBystander(obj,player_clicker_color)
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    if recruit < 2 then
        broadcastToColor("You don't have enough recruit to rescue this bystander!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-2)
    obj.locked = false
    --obj.flip()
    obj.clearButtons()
    obj.setPosition(getObjectFromGUID(vpileguids[player_clicker_color]).getPosition())
end
    
function dontBuyBystander(obj)
    obj.locked = false
    obj.clearButtons()
    obj.flip()
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    local bspos = bsPile.getPosition()
    bspos.y = bspos.y + 2
    obj.setPosition(bspos)
end

function offerBystander(color)
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    if not bsPile then
        bystandersPileGUID = getObjectFromGUID(setupGUID).Call('returnVar',"bystandersPileGUID")
        bsPile = getObjectFromGUID(bystandersPileGUID)
    end
    local pos = getObjectFromGUID(playerBoards[color]).getPosition()
    pos.y = pos.y + 8
    local angle = 180
    if color == "White" then
        pos.z = pos.z - 6
        angle = 90
    elseif color == "Blue" then
        pos.z = pos.z + 6
        angle = -90
    else
        pos.x = pos.x - 6
    end
	local brot = {x=0, y=angle, z=0}

    local lockAndButton = function(obj)
        obj.locked = true
        obj.createButton({click_function='buyBystander',
            function_owner=self,
            position={0,20,1},
            label="Rescue 2*",
            tooltip="Rescue this bystander for 2*.",
            font_size=300,
            font_color="Yellow",
            color={0,0,0},
            width=650,height=650})
        obj.createButton({click_function='dontBuyBystander',
            function_owner=self,
            position={0,20,-1},
            label="Don't",
            tooltip="Don't rescue this bystander for 2*.",
            font_size=300,
            font_color="Red",
            color={0,0,0},
            width=650,height=650})    
    end
    
    bsPile.takeObject({position = pos,
        flip = true,
        smooth = true,
        callback_function = lockAndButton})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            broadcastToColor("Master Strike: KO a bystander from your victory pile or gain a wound.",i,i)
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                local bsguids = {}
                for _,k in pairs(vpilecontent[1].getObjects()) do
                    for _,l in pairs(k.tags) do
                        if l == "Bystander" then
                            table.insert(bsguids,k.guid)
                            break
                        end
                    end
                end
                if #bsguids > 1 then
                    getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = i,
                    pile = vpilecontent[1],
                    guids = bsguids,
                    resolve_function = 'koCard',
                    tooltip = "KO this card.",
                    label = "KO"})
                elseif bsguids[1] then
                    vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                        smooth = true,
                        guid = bsguids[1]})
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                end
            elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                getObjectFromGUID(pushvillainsguid).Call('koCard',vpilecontent[1])
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',i)
            end
        end
    end
    return strikesresolved
end