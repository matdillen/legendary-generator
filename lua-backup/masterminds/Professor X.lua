function onLoad()
    mmname = "Professor X"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids",
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

function updateMMProfessorX()
    local bs = Global.Call('get_decks_and_cards_from_zone',self.guid)
    local boost = 0
    if bs[1] then
        boost = math.abs(bs[1].getQuantity())
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = boost,
        label = "+" .. boost,
        tooltip = "Professor X gets +1 for each of his telepathic pawns.",
        f = 'updateMMProfessorX',
        f_owner = self})
end

function click_buy_pawn(obj,player_clicker_color)
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
        hulkdeck.setRotationSmooth(brot)
        hulkdeck.setPositionSmooth(dest)
    else
        hulkdeck.takeObject({position=dest,rotation=brot,flip=false,smooth=true})
    end
end

function setupMM()
    self.createButton({
         click_function="click_buy_pawn", 
         function_owner=self,
         position={0,0,-0.75},
         rotation={0,180,0},
         label="Buy Pawn",
         tooltip="Buy the top card of Professor X's telepathic pawns.",
         color={1,1,1,1},
         width=800,
         height=200,
         font_size = 100
    })
    
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMProfessorX,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMProfessorX,0.1)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local strikeloc = params.strikeloc

    local costs = {}
    local strikeZone = getObjectFromGUID(strikeloc)
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then
            broadcastToAll("Hero not found in HQ. Abort script")
            return nil
        end
        costs[i] = hasTag2(hero,"Cost:") or 0
    end
    local costs2 = table.sort(table.clone(costs))
    local maxv = {costs2[#costs2],costs2[#costs2-1]}
    broadcastToAll("Master Strike: Choose the two highest-cost Allies in the Lair. Stack them next to Professor X as \"Telepathic Pawns.\".")
    if costs2[#costs2-2] < maxv[2] then
        for i,o in pairs(costs) do
            if o >= maxv[2] then
                local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
                hero.setPositionSmooth(strikeZone.getPosition())
                getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
            end
        end
    elseif maxv[1] > maxv[2] then
        local otherguids = {}
        for i,o in pairs(costs) do
            local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
            if o == maxv[1] then
                hero.setPositionSmooth(strikeZone.getPosition())
                getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
            elseif o == maxv[2] then
                table.insert(otherguids,hero)
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = otherguids,
            pos = strikeZone.getPosition(),
            label = "Dom",
            tooltip = "Professor X dominates this hero as a telepathic pawn."})
    elseif maxv[1] == maxv[2] then
        local otherguids = {}
        for i,o in pairs(costs) do
            local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
            if o == maxv[1] then
                table.insert(otherguids,hero)
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = otherguids,
            n = 2,
            pos = strikeZone.getPosition(),
            label = "Dom",
            tooltip = "Professor X dominates this hero as a telepathic pawn."})
    end
    return strikesresolved
end