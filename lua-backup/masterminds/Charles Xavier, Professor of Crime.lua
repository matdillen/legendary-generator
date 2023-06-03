function onLoad()
    mmname = "Charles Xavier, Professor of Crime"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids",
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function updateMMCharles()
    local bsfound = 0
    for i=2,#city_zones_guids do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[i])
        if citycontent[1] then
            for _,o in pairs(citycontent) do
                if o.hasTag("Bystander") then
                    bsfound = bsfound + 1
                end
            end
        end
    end
    for _,o in pairs(hqguids) do
        local hqcontent = getObjectFromGUID(o).Call('getCards')
        if hqcontent[1] then
            for _,o in pairs(hqcontent) do
                if o.tag == "Card" and o.hasTag("Bystander") then
                    bsfound = bsfound + 1
                elseif o.tag == "Deck" then
                    for _,c in pairs(o.getObjects()) do
                        for _,tag in pairs(c.tags) do
                            if tag == "Bystander" then
                                bsfound = bsfound + 1
                                break
                            end
                        end
                    end
                end
            end
        end   
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = bsfound,
        label = "+" .. bsfound,
        tooltip = "Charles Xavier gets +1 for each Bystander in the city and HQ.",
        f = 'updateMMCharles',
        f_owner = self})
end

function setupMM()
    updateMMCharles()
    
    function onObjectEnterZone(zone,object)
        if object.hasTag("Bystander") then
            updateMMCharles()
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.hasTag("Bystander") then
            updateMMCharles()
        end
    end
end

function noWitness(obj)
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        local pos = hero.getPosition()
        pos.y = pos.y + 3
        pos.z = pos.z - 2
        if hero.guid ~= obj.guid then
            getObjectFromGUID(pushvillainsguid).Call('addBystanders',{cityspace = o,
                face = false,
                pos = pos})
        end
        hero.clearButtons()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    broadcastToAll("Master Strike: Choose a HQ zone to which NO hidden witness will be added!")
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then
            broadcastToAll("Missing hero. Script failed.")
            return nil
        end
        hero.createButton({click_function="noWitness",
            function_owner=self,
            position={0,22,0},
            label="Exclude",
            tooltip="Don't put a hidden witness here.",
            font_size=250,
            font_color="Black",
            color={1,1,1},
            width=750,height=450})
    end
    return strikesresolved
end
