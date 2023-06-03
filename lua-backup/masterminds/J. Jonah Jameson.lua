function onLoad()
    mmname = "J. Jonah Jameson"
    
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID",
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMJonah()
    if self.tag == "Deck" then
        return nil
    end
    local angrymob = 4
    if epicness then
        angrymob = 5
    end
    local checkvalue = 1
    if not Global.Call('get_decks_and_cards_from_zone',self.guid)[1] then
        self.clearButtons()
        checkvalue = 0
    else
        if not self.getButtons() then
            self.createButton({click_function='updateMMJonah',
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label=angrymob,
                tooltip="You can pacify these Angry Mobs for " .. angrymob .. " to have any player gain them.",
                font_size=250,
                font_color="Red",
                width=0})
            self.createButton({click_function="click_pacify_angry_mob", 
                 function_owner=self,
                 position={0,0,0.5},
                 rotation={0,180,0},
                 label="Pacify",
                 tooltip="Pacify this Angry Mob by fighting it and gain a random hero from it.",
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
        tooltip = "You can't fight J. Jonah while he has any Angry Mobs.",
        f = 'updateMMJonah',
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    local soPile = getObjectFromGUID(officerDeckGUID)
    soPile.randomize()
    local jonah = 2
    if epicness then
        jonah = 3
    end
    for i=1,jonah*#Player.getPlayers() do
        soPile.takeObject({position = self.getPosition(),
            flip=false,
            smooth=false})
    end
    self.createButton({click_function="click_pacify_angry_mob", 
             function_owner=self,
             position={0,0,0.5},
             rotation={0,180,0},
             label="Pacify",
             tooltip="Pacify this Angry Mob by fighting it and gain a random hero from it.",
             color={0,0,0,1},
             font_color = {1,0,0},
             width=500,
             height=200,
             font_size = 100})
    updateMMJonah()
    function onObjectEnterZone(zone,object)
        if zone.guid == self.guid then
            updateMMJonah()
        end
    end
    function onObjectLeaveZone(zone,object)
        if zone.guid == self.guid then
            updateMMJonah()
        end
    end
end
    
function click_pacify_angry_mob(obj,player_clicker_color)
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not hulkdeck then
        return nil
    end
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local dest = playerBoard.positionToWorld(pos_discard)
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

function shuffleIntoMobs(params)
    local obj = params.obj
    
    obj.setPosition(self.getPosition())
    obj.flip()
    if epicness and (not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") == 0) then
        getObjectFromGUID(pushvillainsguid).Call('getWound',params.player_clicker_color)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    for _,o in pairs(Player.getPlayers()) do
        local investigateMobs = function()
            local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')[1]
            local deckcontent = deck.getObjects()
            local investiguids = {deckcontent[1].guid,deckcontent[2].guid}
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                pile = deck,
                guids = investiguids,
                resolve_function = 'shuffleIntoMobs',
                tooltip = "Shuffle this card into the Angry Mobs stack.",
                label = "Shuffle",
                args = "self",
                flip = true,
                fsourceguid = self.guid})
        end
        local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
        if not deck[1] or deck[1].getQuantity() < 2 then
            getObjectFromGUID(playerBoards[o.color]).Call('refillDeck')
            Wait.time(investigateMobs,1)
        else
            investigateMobs()
        end
    end
    return strikesresolved
end