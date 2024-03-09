function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
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

function bonusInCity(params)
    if params.object.getName() == "Frost Giant Invader" then
    local resp = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{
        trait = "4", 
        prefix = "Cost:", 
        what = "Cost", 
        players = {Player[Turns.turn_color]}})[1]
    if resp then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{
            obj= params.object,
            label = "+4",
            zoneguid = params.zoneguid,
            tooltip = "You are not worthy so giant is bigger.",
            id="notworthy"})
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    cards[1].setName("Frost Giant Invader")
    cards[1].setTags({"VP6","Power:6","Villain"})
    cards[1].setDescription("If you are not Worthy (reveal a Hero that costs 5 or more), Frost Giant Invader gets +4.")
    broadcastToAll("Scheme Twist: The twist cards enters the city as a Frost Giant Invader!")
    if twistsresolved == 8 or twistsresolved == 9 then
        local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
        pos.y = pos.y + 2
        local giantsfound = 0
        for _,o in pairs(Player.getPlayers()) do
            local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])
            if vpile[1] and vpile[1].tag == "Deck" then
                for _,obj in pairs(vpile[1].getObjects()) do
                    if obj.name == "Frost Giant Invader" then
                        vpile[1].takeObject({position = pos,
                            guid = obj.guid,
                            flip = true})
                        giantsfound = giantsfound + 1
                        break
                    end
                end
            elseif vpile[1] and vpile[1].getName() == "Frost Giant Invader" then
                vpile[1].flip()
                vpile[1].setPositionSmooth(pos)
                giantsfound = giantsfound + 1
            end
        end
        if giantsfound > 0 then
            Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=giantsfound}) end,2.5)
            broadcastToAll("Scheme Twist: " .. giantsfound .. " Frost Giant Invaders played from player's victory piles!")
        end
    end
    return twistsresolved
end