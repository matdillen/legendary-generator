function onLoad()
    mmname = "Nimrod, Super Sentinel"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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
        "playerBoards",
        "resourceguids"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMNimrod()
    local checkvalue = 0
    if getObjectFromGUID(resourceguids[Turns.turn_color]).Call('returnPeakVal') < 6 then
        checkvalue = 1
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
            checkvalue = checkvalue,
            label = "X",
            tooltip = "You can't fight Nimrod unless you made six Recruit this turn.",
            id = "nimrodispoorneedsmoney",
            f = 'updateMMNimrod',
            f_owner = self})
end

function setupMM()
    updateMMNimrod()
    function onObjectEnterZone(zone,object)
        updateMMNimrod()
    end
    function onObjectLeaveZone(zone,object)
        updateMMNimrod()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city
    local mmname = params.mmname
    local epicness = params.epicness
    local mmloc = params.mmloc
    local strikeloc = params.strikeloc

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver")
    broadcastToAll("Master Strike: Each player with no silver hero discards all hero cards with a Recruit or all cards with an Attack symbol.")
    for _,p in pairs(players) do
        local playerboard = getObjectFromGUID(playerBoards[p.color])
        _G["nimrodDiscardRecruit" .. p.color] = function(obj)
            local butt = obj.getButtons()
            for i,o in pairs(butt) do
                if o.click_function:find("nimrodDiscard") then
                    obj.removeButton(i-1)
                end
            end
            for i,o in pairs(playerBoards) do
                if o == obj.guid then
                    local hand = Player[i].getHandObjects()
                    for _,card in pairs(hand) do
                        if hasTag2(card,"Recruit:") then
                            card.setPosition(getObjectFromGUID(o).positionToWorld(pos_discard))
                        end
                    end
                    break
                end
            end
        end
        _G["nimrodDiscardAttack" .. p.color] = function(obj)
            local butt = obj.getButtons()
            for i,o in pairs(butt) do
                if o.click_function:find("nimrodDiscard") then
                    obj.removeButton(i-1)
                end
            end
            for i,o in pairs(playerBoards) do
                if o == obj.guid then
                    local hand = Player[i].getHandObjects()
                    for _,card in pairs(hand) do
                        if hasTag2(card,"Attack:") then
                            card.setPosition(getObjectFromGUID(o).positionToWorld(pos_discard))
                        end
                    end
                    break
                end
            end
        end
        playerboard.createButton({click_function="nimrodDiscardRecruit" .. p.color,
            function_owner=self,
            position={0,3,5},
            label="Recruit",
            tooltip="Discard all cards with a Recruit symbol.",
            font_size=250,
            font_color="Black",
            color={1,1,0},
            width=750,height=450})
        playerboard.createButton({click_function="nimrodDiscardAttack" .. p.color,
            function_owner=self,
            position={0,3,6},
            label="Attack",
            tooltip="Discard all cards with an Attack symbol.",
            font_size=250,
            font_color="Black",
            color={1,0,0},
            width=750,height=450})
    end
    return strikesresolved
end