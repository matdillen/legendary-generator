function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    
    local guids3 = {
        "playguids"
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

function setupCounter(init)
    if init then
        local playercounter = 2*#Player.getPlayers()
        return {["tooltip"] = "Villains escaped: __/" .. playercounter .. ".",
                ["zoneguid"] = escape_zone_guid,
                ["tooltip2"] = "Villain deck count: __.",
                ["zoneguid2"] = villainDeckZoneGUID}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Villain"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Villain") then
            counter = counter + 1
        end
        return counter
    end
end

function setupCounter2()
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck then
        return math.abs(vildeck.getQuantity())
    else
        return 0
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    local color = Turns.turn_color
    for _,o in pairs(Player.getPlayers()) do
        local rot = 180
        if o.color == "White" then
            rot = 0
        else
            rot = 180
        end
        local playzone = getObjectFromGUID(playguids[o.color])
        playzone.createButton({click_function='updatePower',
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,rot,0},
            scale={0.25,0.5,1},
            label="You can only play cards from a single Team of your choice!!",
            tooltip="Play restriction because of Scheme Twist!",
            font_size=75,
            font_color={1,0.1,0},
            color={0,0,0},
            width=0})
    end
    local turnHasPassed = function()
        if Turns.getPreviousTurnColor() == color then
            return true
        else 
            return false
        end
    end
    local killButtonCallback = function()
        local turnAgain = function()
            if Turns.turn_color == color then
                return true
            else 
                return false
            end
        end
        local killButton = function()
            for _,o in pairs(Player.getPlayers()) do
                local playzone = getObjectFromGUID(playguids[o.color])
                playzone.removeButton(0)
            end
        end
        Wait.condition(killButton,turnAgain)
    end
    Wait.condition(killButtonCallback,turnHasPassed)
    return twistsresolved
end