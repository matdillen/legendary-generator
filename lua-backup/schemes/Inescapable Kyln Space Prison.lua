function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "resourceguids",
        "attackguids"
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

function imprisonandmix()
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            hero.flip()
        end
    end
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getCards')
        hero[1].setPosition(getObjectFromGUID(hqguids[1]).getPosition())
    end
    Wait.time(
        function()
            local heroes = Global.Call('get_decks_and_cards_from_zone',hqguids[1])[1]
            heroes.randomize()
            for i=1,4 do
                heroes.takeObject({position = getObjectFromGUID(hqguids[i+1]).getPosition(),
                    smooth = true,
                    flip = false,
                    callback_function = 'imprison'})
            end
        end,0.5)
end

function imprison()
    for _,o in pairs(hqguids) do
        local zone = getObjectFromGUID(o)
        zone.editButton({index = 1,
            click_function = 'liberate',
            function_owner = self,
            label = "Liberate",
            tooltip = "Liberate for 1 attack."})
    end
end

function liberate(obj,player_clicker_color)
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < 1 then
        broadcastToColor("You don't have enough attack to liberate this imprisoned hero!",player_clicker_color,player_clicker_color)
        return nil
    else
        obj.editButton({index = 1,
            click_function = 'click_buy_hero',
            function_owner = obj,
            label = "Buy hero",
            tooltip = ""})
        getObjectFromGUID(attackguids[player_clicker_color]).Call('updateVal',-1)
    end
end

function escapePlan(obj,player_clicker_color)
    if color == "Red" then
        local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
        if attack < val then
            broadcastToColor("You don't have enough attack to acquire this part of the plan!",player_clicker_color,player_clicker_color)
            return nil
        else
            self.clearButtons()
            getObjectFromGUID(attackguids[player_clicker_color]).Call('updateVal',-val)
        end
    elseif color == "Yellow" then
        local attack = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
        if attack < val then
            broadcastToColor("You don't have enough recruit to acquire this part of the plan!",player_clicker_color,player_clicker_color)
            return nil
        else
            self.clearButtons()
            getObjectFromGUID(resourceguids[player_clicker_color]).Call('updateVal',-val)
        end
    end
end

function dummy()
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    if twistsresolved < 4 then
        val = 3
        component = "a Quarnyx Battery."
        color = "Red"
    elseif twistsresolved > 3 and twistsresolved < 6 then
        val = 5
        component = "a Prison Control Device."
    elseif twistsresolved == 6 then
        val = 6
        component = "That Guy's Leg!"
        color = "Yellow"
    elseif twistsresolved == 7 then
        val = 7
        component = "the Cassette Player."
    elseif twistsresolved == 8 then
        broadcastToAll("Twist 8: Evil Wins!")
        return nil
    end
    
    local toolt = "Spend " .. val .. " this turn to acquire " .. component
    
    self.createButton({click_function='escapePlan',
        function_owner=self,
        position={0,0,-1},
        rotation={0,180,0},
        scale = {1,1,0.5},
        label="Plan",
        tooltip=toolt,
        font_size=300,
        font_color={0,0,0},
        color={1,1,1},
        width=250,height=150})
    self.createButton({click_function='dummy',
        function_owner=self,
        position={0,0,-1},
        rotation={0,180,0},
        scale = {1,1,0.5},
        label=val,
        tooltip="",
        font_size=300,
        font_color=color,
        color={0,0,0,0.75},
        width=250,height=150})
    local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
    local oldcolor = Turns.turn_color
    local planfails = function()
        if self.getButtons() then
            self.clearButtons()
            getObjectFromGUID(pushvillainsguid).Call('getWound',oldcolor)
            
        end
    end
    local turnchange = function()
        if Turns.turn_color == nextcolor then
            return true
        else
            return false
        end
    end
    Wait.condition(planfails,turnchange)
    return twistsresolved
end