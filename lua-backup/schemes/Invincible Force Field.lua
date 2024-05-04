function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids3 = {
        "attackguids",
        "resourceguids"
        }
            
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end

    mmzone = getObjectFromGUID(mmZoneGUID)
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

function fightEffect(params)
    if params.obj.guid == mmZoneGUID and params.mm == true then
        shiftButtons()
    end
end

function shiftButtons(turnend)
    local butt = mmzone.getButtons()
    local createnew = false
    for i,b in pairs(butt) do
        if not turnend and (b.click_function == "payRecruit" or b.click_function == "payAttack") then
            mmzone.removeButton(i)
            if not createnew then
                mmzone.Call('fightButton',mmZoneGUID)
                local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
                Wait.condition(
                    function()
                        shiftButtons(true) 
                    end,
                    function()
                        if Turns.turn_color == nextcolor then
                            return true
                        else
                            return false
                        end
                    end)
                createnew = true
            end
        elseif b.click_function:find("fightEffect") then
            mmzone.removeButton(i)
            ffbuttons()
            break
        end
    end
end

function ffbuttons()
    mmzone.createButton({click_function='payRecruit',
        function_owner=self,
        position={0.5,0,0},
        rotation={0,180,0},
        label="+" .. twistsresolved .. "/",
        tooltip="Spend this much Recruit to fight the Mastermind.",
        font_size=350,
        font_color="Yellow",
        color={0,0,0,0.75},
        width=250,height=250})
    mmzone.createButton({click_function='payAttack',
        function_owner=self,
        position={-0.5,0,0},
        rotation={0,180,0},
        label="+" .. twistsresolved,
        tooltip="Spend this much Attack to fight the Mastermind.",
        font_size=350,
        font_color="Red",
        color={0,0,0,0.75},
        width=250,height=250})
end

function payRecruit(obj,player_clicker_color)
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    if recruit < twistsresolved then
        broadcastToColor("You don't have enough recruit to remove the Mastermind's Force Field!",player_clicker_color,player_clicker_color)
        return nil
    else
        shiftButtons()
        getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-twistsresolved)
    end
end

function payAttack(obj,player_clicker_color)
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < twistsresolved then
        broadcastToColor("You don't have enough attack to remove the Mastermind's Force Field!",player_clicker_color,player_clicker_color)
        return nil
    else
        shiftButtons()
        getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-twistsresolved)
    end
end

function resolveTwist(params)
    twistsresolved = params.twistsresolved 
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved == 1 then
        ffbuttons()
    elseif twistsresolved < 7 then
        local butt = mmzone.getButtons()
        for i,b in pairs(butt) do
            if b.click_function == "payRecruit" then
                mmzone.editButton({index = i,
                    label = "+" .. twistsresolved .. "/"})
            elseif b.click_function == "payAttack" then
                    mmzone.editButton({index = i,
                label = "+" .. twistsresolved}) 
            end
        end
    else
        broadcastToAll("Scheme Twist: Evil Wins!")
    end
    return nil
end