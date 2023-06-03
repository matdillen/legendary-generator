function onLoad()
    mmname = "Madelyne Pryor, Goblin Queen"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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
        "playerBoards"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
end

function click_buy_goblin(obj,player_clicker_color)
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
        hulkdeck.setRotationSmooth(brot)
        hulkdeck.setPositionSmooth(dest)
    else
        broadcastToColor("Choose a Bystander to rescue.",player_clicker_color,player_clicker_color)
        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = player_clicker_color,
            pile = hulkdeck,
            targetpos = pos_vp2,
            label = "Rescue",
            tooltip = "Rescue this bystander."})
    end
end

function updateMMMadelyne()
    if self.tag == "Deck" then
        return nil
    end
    local checkvalue = 1
    if not Global.Call('get_decks_and_cards_from_zone',self.guid)[1] then
        self.clearButtons()
        checkvalue = 0
    else
        if not self.getButtons() then
            self.createButton({click_function='updateMMMadelyne',
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="2",
                tooltip="You can fight these Demon Goblins for 2 to rescue them as Bystanders.",
                font_size=250,
                font_color="Red",
                width=0})
            self.createButton({
                click_function="click_buy_goblin", 
                function_owner=self,
                position={0,0,0.5},
                rotation={0,180,0},
                label="Fight",
                tooltip="Fight one of the goblins to rescue it as a bystander.",
                color={0,0,0,1},
                font_color = {1,0,0},
                width=500,
                height=200,
                font_size = 100
            })
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = checkvalue,
        label = "X",
        tooltip = "You can't fight Madelyne Pryor while she has any Demon Goblins.",
        f = 'updateMMMadelyne',
        f_owner = self})
end

function setupMM()
    updateMMMadelyne()
    function onObjectEnterZone(zone,object)
        updateMMMadelyne()
    end
    function onObjectLeaveZone(zone,object)
        updateMMMadelyne()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local strikeloc = params.strikeloc

    local madsbs = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    if madsbs[1] then
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    end
    for i =1,4 do
        getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = strikeloc,
            posabsolute = true})
    end
    return strikesresolved
end