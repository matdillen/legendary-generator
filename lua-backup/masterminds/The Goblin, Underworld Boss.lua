function onLoad()
    mmname = "The Goblin, Underworld Boss"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "bystandersPileGUID",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_vp2"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    
    local guids3 = {
        "vpileguids",
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

function click_save_goblin_hw(obj,player_clicker_color)
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not hulkdeck then
        return nil
    end
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local dest = playerBoard.positionToWorld(pos_vp2)
    dest.y = dest.y + 3
    if player_clicker_color == "White" then
        angle = 90
    elseif player_clicker_color == "Blue" then
        angle = -90
    else
        angle = 180
    end
    local brot = {x=0, y=angle, z=0}
    if hulkdeck.tag == "Card" then
        hulkdeck.flip()
        hulkdeck.setRotationSmooth(brot)
        hulkdeck.setPositionSmooth(dest)
    else
        hulkdeck.takeObject({position = dest,
            flip = true,
            smooth = true,
            index = math.random(hulkdeck.getQuantity())-1})
    end
end

function updateMMTheGoblin()
    local checkvalue = 1
    if not Global.Call('get_decks_and_cards_from_zone',self.guid)[1] then
        self.clearButtons()
        checkvalue = 0
    else
        if not self.getButtons() then
            self.createButton({click_function='updateMMTheGoblin',
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label=2,
                tooltip="You can save these Hidden Witnesses for 2 Recruit to rescue them as Bystanders.",
                font_size=250,
                font_color="Yellow",
                width=0})
            self.createButton({click_function='click_save_goblin_hw', 
                 function_owner=self,
                 position={0,0,0.5},
                 rotation={0,180,0},
                 label="Save",
                 tooltip="Save a Hidden Witness by paying 2 recruit and rescue it as a bystander.",
                 color={0,0,0,1},
                 font_color = {1,0,0},
                 width=500,
                 height=200,
                 font_size = 100})
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
            checkvalue = checkvalue,
            label = "X",
            tooltip = "You can't fight The Goblin while he has any Hidden Witnesses.",
            f = 'updateMMTheGoblin',
            f_owner = self})
end

function setupMM()
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    if not bsPile then
        bystandersPileGUID = getObjectFromGUID(setupGUID).Call('returnVar',"bystandersPileGUID")
        bsPile = getObjectFromGUID(bystandersPileGUID)
    end
    for i=1,2 do
        bsPile.takeObject({position=self.getPosition(),
            flip=false,
            smooth=false})
    end
    
    self.createButton({click_function='click_save_goblin_hw', 
             function_owner=self,
             position={0,0,0.5},
             rotation={0,180,0},
             label="Save",
             tooltip="Save a Hidden Witness by paying 2 recruit and rescue it as a bystander.",
             color={0,0,0,1},
             font_color = {1,0,0},
             width=500,
             height=200,
             font_size = 100})
    
    updateMMTheGoblin()
    function onObjectEnterZone(zone,object)
        updateMMTheGoblin()
    end
    function onObjectLeaveZone(zone,object)
        updateMMTheGoblin()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local strikeloc = params.strikeloc

    local shieldspresent = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    local shieldcount = 0
    if shieldspresent[1] then
        shieldcount = math.abs(shieldspresent[1].getQuantity())
    end
    local bsadded = 0
    for _,o in pairs(Player.getPlayers()) do
        local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])
        if vpile[1] and vpile[1].tag == "Deck" then
            local bsguids = {}
            for _,obj in pairs(vpile[1].getObjects()) do
                for _,k in pairs(obj.tags) do
                    if k == "Bystander" then
                        table.insert(bsguids,obj.guid)
                        break
                    end
                end
            end
            local guid = nil
            if #bsguids > 1 then
                bsadded = bsadded + 2
                guid = table.remove(bsguids,math.random(#bsguids))
                vpile[1].takeObject({position = self.getPosition(),
                    flip=true,
                    guid=guid,
                    smooth=true})
                if not vpile[1].remainder then
                    guid = table.remove(bsguids,math.random(#bsguids))
                    vpile[1].takeObject({position = self.getPosition(),
                        flip=true,
                        guid=guid,
                        smooth=true})
                else
                    vpile[1].remainder.flip()
                    vpile[1].remainder.setPositionSmooth(self.getPosition())
                end
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
            end
        else
            getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
        end
    end
    if bsadded > 0 then
        local shuffleShields = function()
            Global.Call('get_decks_and_cards_from_zone',strikeloc)[1].randomize()
        end
        local shieldsAdded = function()
            local shields = Global.Call('get_decks_and_cards_from_zone',strikeloc)
            if shields[1] and math.abs(shields[1].getQuantity()) == bsadded + shieldcount then
                return true
            else
                return false
            end
        end
        Wait.condition(shuffleShields,shieldsAdded)
    end
    return strikesresolved
end