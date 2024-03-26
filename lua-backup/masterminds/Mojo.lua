function onLoad()
    mmname = "Mojo"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "setupGUID",
        "bystandersPileGUID",
        "villainDeckZoneGUID",
        "bszoneguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
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

function setupSpecial(params)
    setupParts = table.clone(params.setupParts)
    local bscount = setupParts[3]
    setupParts[3] = 0
    return {["setupParts"] = setupParts,
            ["vildeckc"] = bscount}
end

function updateMMMojo()
    local checkvalue = 1
    if not Global.Call('get_decks_and_cards_from_zone',self.guid)[1] then
        self.clearButtons()
        checkvalue = 0
    else
        if not self.getButtons() then
            self.createButton({click_function='updateMMMojo',
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label=mojobasepower,
                tooltip="You can fight these Human Shields for " .. mojobasepower .. " to rescue them as Bystanders.",
                font_size=250,
                font_color="Red",
                width=0})
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
            checkvalue = checkvalue,
            label = "X",
            tooltip = "You can't fight Mojo while he has any Human Shields.",
            f = 'updateMMMojo',
            id = "mojohasshield",
            f_owner = self})
end

function setupMM(params)
    epicness = params.epicness

    local bsCount = 0
    if setupParts then
        bsCount = setupParts[3]
    end
    mojoVPUpdate(bsCount,epicness)
    mojobasepower = 6
    if epicness then
        getObjectFromGUID(setupGUID).Call('playHorror')
        mojobasepower = 7
    end
    
    updateMMMojo()
    function onObjectEnterZone(zone,object)
        updateMMMojo()
    end
    function onObjectLeaveZone(zone,object)
        updateMMMojo()
    end
end

function mojoVPUpdate(bsCount,epicness)
    if not bsCount then
        bsCount = 0
    end
    local mojo = 3
    local mojovp = 3
    if epicness == true then
        mojo = 6
        mojovp = 4
    end
    local mojotagf = function(obj)
        obj.removeTag("VP1")
        obj.addTag("VP3")
    end
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    local bspilecount = bsPile.getQuantity()
    local mojopos = bsPile.getPosition()
    local bsflip = true
    for i=1,bspilecount do
        if i <= bsCount then
            mojopos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
            bsflip = true
        elseif i <= mojo + bsCount then
            mojopos = getObjectFromGUID(getObjectFromGUID(mmZoneGUID).Call('getStrikeloc',"Mojo")).getPosition()
            bsflip = false
        else 
            mojopos = bsPile.getPosition()
            mojopos.y = mojopos.y +2
            bsflip = false
        end
        bsPile.takeObject({position = mojopos,
            smooth = false,
            flip = bsflip,
            callback_function = mojotagf})
        if bsPile.remainder then
            mojotagf(bsPile.remainder)
            break
        end
    end
    local bsTagged = function()
        local bsdeck = Global.Call('get_decks_and_cards_from_zone',bszoneguid)
        if bsdeck[1] and bsdeck[1].getQuantity() == bspilecount - bsCount - mojo then
            return true
        else
            return false
        end
    end
    local setNewBSGUID = function()
        local bsDeck = Global.Call('get_decks_and_cards_from_zone',bszoneguid)
        getObjectFromGUID(pushvillainsguid).Call('updateVar',{varname = "bystandersPileGUID",
            varvalue = bsDeck[1].guid})
        log("bs pile guid = ")
        log(bsDeck[1].guid)
    end
    local timerSetNewGUID = function()
        Wait.condition(setNewBSGUID,bsTagged)
    end
    Wait.time(timerSetNewGUID,2)
    broadcastToAll("Mojo! Bystanders net " .. mojovp .. " victory points each!")
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local city = params.city
    local epicness = params.epicness
    local strikeloc = params.strikeloc
    
    getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = strikeloc,
        face = false,
        posabsolute = true})
    if epicness then
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,p in pairs(citycontent) do
                    if p.hasTag("Group:Mojoverse") then
                        getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = o,face = false})
                        break
                    end
                end
            end
        end
    end
    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver")
    for _,o in pairs(players) do
        local hand = o.getHandObjects()
        if epicness and #hand > 4 then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                n = #hand-4})
            broadcastToColor("Master Strike: Discard down to 4 cards.",o.color,o.color)
        else
            if #hand > 0 then
                local posdiscard = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard)
                hand[math.random(#hand)].setPosition(posdiscard)
            end
            broadcastToColor("Master Strike: Discard a card at random.",o.color,o.color)
        end
    end
    return strikesresolved
end