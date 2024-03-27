function onLoad()
    mmname = "Wasteland Hulk"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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

function updateMMWastelandHulk()
    local tacticsfound = 0
    for _,o in pairs(Player.getPlayers()) do
        local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])
        if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
            for _,o in pairs(vpilecontent[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k == "Tactic:Wasteland Hulk" then
                        tacticsfound = tacticsfound + 1
                        break
                    end
                end
            end
        elseif vpilecontent[1] and vpilecontent[1].hasTag("Tactic:Wasteland Hulk") then
            tacticsfound = tacticsfound + 1
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = tacticsfound,
        label = "+" .. tacticsfound*3,
        tooltip = "Wasteland Hulk gets +3 for each of his Mastermind Tactics among all players' Victory Piles.",
        f = 'updateMMWastelandHulk',
        id = "wastelandhulkrevenge",
        f_owner = self})
end

function setupMM()
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMWastelandHulk,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMWastelandHulk,0.1)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    getObjectFromGUID(pushvillainsguid).Call('crossDimensionalRampage',"hulk")
    return strikesresolved
end