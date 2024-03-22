function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playerBoards",
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function bonusInCity(params)
    if params.object.hasTag("Villain") then
        local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[Turns.turn_color])[1]
        local bonus = 0
        if vpilecontent and vpilecontent.tag == "Deck" then
            for _,o in pairs(vpilecontent.getObjects()) do
                for _,t in pairs(o.tags) do
                    if t == hasTag2(params.object,"Group:") then
                        bonus = bonus + 1
                        break
                    end
                end
            end
        elseif vpilecontent then
            if hasTag2(vpilecontent,"Group:") and hasTag2(vpilecontent,"Group:") == hasTag2(params.object,"Group:") then
                bonus = bonus + 1
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{
            obj= params.object, 
            label = "+" .. bonus,
            zoneguid = params.zoneguid,
            tooltip = "This villain gets +1 Power for each card of their villain group in the attacking player's Victory Pile.",
            id = "dprevenge"})
    end
end

function nonTwist(params)
    local obj = params.obj
    
    if obj.hasTag("Villain") then
        if obj.getDescription() == "" then
            obj.setDescription("REVENGE: This villain gets +1 Power for each card of the listed group in the attacking player's Victory Pile.")
        else
            obj.setDescription(obj.getDescription() .. "\r\nREVENGE: This villain gets +1 Power for each card of the listed group in the attacking player's Victory Pile.")
        end
    end
    return 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local deadpoolinhand = {}
    local deadpoolloser = nil
    for i,o in pairs(playerBoards) do
        if Player[i].seated == true then
            local hand = Player[i].getHandObjects()
            if hand then
                local deadpoolcount = 0
                for _,card in pairs(hand) do
                    local team = hasTag2(card,"Team:",6)
                    if team and team == "Deadpool" or card.getName() == "Deadpool (B)" then
                        deadpoolcount = deadpoolcount + 1
                    end
                end
                deadpoolinhand[i] = deadpoolcount
                if not deadpoolloser then
                    deadpoolloser = deadpoolcount
                else
                    deadpoolloser = math.min(deadpoolloser,deadpoolcount)
                end
            end
        end
    end
    for i,o in pairs(deadpoolinhand) do
        if o == deadpoolloser then
            getObjectFromGUID(pushvillainsguid).Call('getWound',i)
            broadcastToAll("Scheme Twist: Player " .. i .. " fell short on amazing Deadpools and was wounded for it.",i)
        end
    end
    return twistsresolved
end