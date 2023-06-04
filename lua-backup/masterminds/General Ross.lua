function onLoad()
    mmname = "General Ross"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "bystandersPileGUID",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    mmZone = getObjectFromGUID(mmZoneGUID)

    local guids3 = {
        "vpileguids"
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

function setupMM()
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    if not bsPile then
        bystandersPileGUID = getObjectFromGUID(setupGUID).Call('returnVar',"bystandersPileGUID")
        bsPile = getObjectFromGUID(bystandersPileGUID)
    end
    for i=1,8 do
        bsPile.takeObject({position=getObjectFromGUID(self.guid).getPosition(),
            flip=false,
            smooth=true})
    end
    
    mmloc = getObjectFromGUID(mmZone.Call('returnMMLocation',mmname))
    
    function onPlayerTurn(player,previous_player)
        local transformed = mmZone.Call('returnTransformed',mmname)
        if transformed and transformed == true then
            updateMMRoss()
        end
    end

    function onObjectEnterZone(zone,object)
        local transformed = mmZone.Call('returnTransformed',mmname)
        if transformed ~= nil then
            updateMMRoss()
        end
    end

    function onObjectLeaveZone(zone,object)
        local transformed = mmZone.Call('returnTransformed',mmname)
        if transformed ~= nil then
            updateMMRoss()
        end
    end
end

function updateMMRoss()
    if self.tag == "Deck" then
        return nil
    end
    local buttonindex = nil
    for i,o in pairs(mmloc.getButtons()) do
        if o.click_function == "updateMMRoss" then
            buttonindex = i-1
            break
        end
    end
    local strikeloc = self.guid
    local checkvalue = 1
    local transformed = mmZone.Call('returnTransformed',mmname)
    if transformed == nil then
        return nil
    end
    if transformed == false then
        local helicopters = Global.Call('get_decks_and_cards_from_zone',strikeloc)
        if not helicopters[1] then
            getObjectFromGUID(strikeloc).clearButtons()
            checkvalue = 0
        else
            if not getObjectFromGUID(strikeloc).getButtons() then
                getObjectFromGUID(strikeloc).createButton({click_function='updateMMRoss',
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    label="2",
                    tooltip="You can fight these Helicopter Villains for 2 to rescue them as Bystanders.",
                    font_size=250,
                    font_color="Red",
                    width=0})
            else
                getObjectFromGUID(strikeloc).editButton({label="2",
                    tooltip="You can fight these Helicopter Villains for 2 to rescue them as Bystanders."})
            end
        end
        mmZone.Call('mmButtons',{mmname = mmname,
            checkvalue = 1,
            label = 6,
            tooltip = "Base power as written on the card.",
            f = 'updatePower',
            id = 'card'})
        mmZone.Call('mmButtons',{mmname = mmname,
            checkvalue = 0,
            label = 0,
            tooltip = "Red Hulk no longer gets +1 for each Wound in your discard pile.",
            f = 'updateMMRoss',
            id = "woundedFury",
            f_owner = self})
        mmZone.Call('mmButtons',{mmname = mmname,
            checkvalue = checkvalue,
            label = "X",
            tooltip = "You can't fight General Ross while he has any Helicopters.",
            f = 'updateMMRoss',
            id = "fightRoss",
            f_owner = self})
    elseif transformed == true then
        if getObjectFromGUID(strikeloc).getButtons() then
            getObjectFromGUID(strikeloc).editButton({label="X",
                tooltip="You can't fight Helicopters, and they don't stop you from fighting Red Hulk."})
        else
            getObjectFromGUID(strikeloc).createButton({click_function='updateMMRoss',
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    label="X",
                    tooltip="You can't fight Helicopters, and they don't stop you from fighting Red Hulk.",
                    font_size=250,
                    font_color="Red",
                    width=0})
        end
        mmZone.Call('mmButtons',{mmname = mmname,
            checkvalue = 1,
            label = 9,
            tooltip = "Base power as written on the card.",
            f = 'updatePower',
            id = 'card'})
        mmZone.Call('mmButtons',{mmname = mmname,
            checkvalue = 0,
            label = "",
            tooltip = "You can fight Red Hulk while he has any Helicopters.",
            f = 'updateMMRoss',
            id = "fightRoss",
            f_owner = self})
        local wounds = mmZone.Call('woundedFury')
        mmZone.Call('mmButtons',{mmname = mmname,
            checkvalue = wounds,
            label = "+" .. wounds,
            tooltip = "Red Hulk gets +1 for each Wound in your discard pile.",
            f = 'updateMMRoss',
            id = "woundedFury",
            f_owner = self})
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local mmloc = params.mmloc
    local strikeloc = params.strikeloc

    local transformedPV = mmZone.Call('transformMM',getObjectFromGUID(mmloc))
    if transformedPV == true then
        getObjectFromGUID(pushvillainsguid).Call('crossDimensionalRampage',"hulk")
    elseif transformedPV == false then
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    local bsguids = {}
                    for _,k in pairs(vpilecontent[1].getObjects()) do
                        for _,l in pairs(k.tags) do
                            if l == "Bystander" then
                                bsguids[k.name] = k.guid
                                break
                            end
                        end
                    end
                    if next(bsguids) then
                        local bsnr = math.random(#bsguids)
                        local step = 1
                        for name,guid in pairs(bsguids) do
                            if step == bsnr then
                                if name == "Card" then
                                    name = ""
                                end
                                broadcastToColor("Master Strike: Random bystander " .. name .. " piloted one of General Ross's helicopters.",i,i)
                                vpilecontent[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                                    smooth = false,
                                    flip = true,
                                    guid = guid})
                                break
                            else
                                step = step + 1
                            end
                        end
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                    end
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                    vpilecontent[1].flip()
                    vpilecontent[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                end
            end
        end
    end
    return strikesresolved
end