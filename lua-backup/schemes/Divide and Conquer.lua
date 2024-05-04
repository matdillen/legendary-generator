function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "mmZoneGUID",
        "heroPileGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS",
        "topBoardGUIDs",
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function setupSpecial(params)
    local heroParts = {}
    for s in string.gmatch(params.setupParts[8],"[^|]+") do
        table.insert(heroParts, string.lower(s))
    end
    local dividedDeckGUIDs = {
        ["HC:Red"]="4c1868",
        ["HC:Green"]="8656c3",
        ["HC:Yellow"]="533311",
        ["HC:Blue"]="3d3ba7",
        ["HC:Silver"]="725c5d"
    }
    local tempDeckGUIDs ={
    "1fa829",
    "bf7e87",
    "82ccd7",
    "5bc848",
    "07423f",
    "5a74e7",
    "40b47d"
    }
    local hqhop = 1
    for i,o in pairs(dividedDeckGUIDs) do
        local zone = getObjectFromGUID(o)
        local col = i:sub(4,-1)
        if col == "Silver" then
            col = "White"
        end
        getObjectFromGUID(hqguids[hqhop]).Call('updateVar1',{name = "heroDeckZoneGUID",value = o})
        hqhop = hqhop + 1
        zone.createButton({click_function='updatePower',
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,180,0},
            label=i:sub(4,4),
            tooltip="This is the hero deck for all " .. i:sub(4,-1) .. " heroes.",
            font_size=250,
            font_color=col,
            color={0,0,0,0.75},
            width=10,height=10})
    end
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 3,7 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
    local divideSort = function(obj)
        --log(obj)
        local remo = 0
        for i,o in ipairs(obj.getObjects()) do
            local colors = {}
            for _,tag in pairs(o.tags) do
                if tag:find("HC1:") or tag:find("HC2") then
                    table.insert(colors,"HC:" .. tag:sub(5,-1))
                end
                if tag:find("HC:") then
                    table.insert(colors,tag)
                end
            end
            if #colors > 1 then
                table.remove(colors,math.random(2))
            end
            local dividedDeckZone = getObjectFromGUID(dividedDeckGUIDs[colors[1]])
            if not obj.remainder then
                obj.takeObject({index = i-1-remo,
                    position=dividedDeckZone.getPosition(),
                    smooth=false,
                    flip=true})
                remo = remo + 1
            else
                local temp = obj.remainder
                temp.flip()
                colors = {}
                for _,tag in pairs(temp.getTags()) do
                    if tag:find("HC1:") or tag:find("HC2") then
                        table.insert(colors,"HC:" .. tag:sub(5,-1))
                    end
                    if tag:find("HC:") then
                        table.insert(colors,tag)
                    end
                end
                if #colors > 1 then
                    table.remove(colors,math.random(2))
                end
                dividedDeckZone = getObjectFromGUID(dividedDeckGUIDs[colors[1]])
                temp.setPosition(dividedDeckZone.getPosition())
            end
        end
    end
    local heroPile = getObjectFromGUID(heroPileGUID)
    for i,o in pairs(heroParts) do
        for _,object in pairs(heroPile.getObjects()) do
            if o == string.lower(object.name) then
                log ("Found hero: " .. object.name)
                local heroGUID = object.guid
                local tempZone = getObjectFromGUID(tempDeckGUIDs[i])
                heroPile.takeObject({guid=heroGUID,
                    position=tempZone.getPosition(),
                    smooth=false,flip=true,
                    callback_function=divideSort})
            end
        end
    end
    local newSetupParts = table.clone(params.setupParts)
    newSetupParts[8] = ""
    return {["setupParts"] = newSetupParts}
end

function koThisHeroDeck(params)
    local content = Global.Call('get_decks_and_cards_from_zone',params.obj.guid)[1]
    content.flip()
    getObjectFromGUID(pushvillainsguid).Call('koCard',content)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    if twistsresolved < 4 then
        for _,o in pairs(hqguids) do
            local hqzone = getObjectFromGUID(o)
            local herocard = hqzone.Call('getHeroUp')
            if herocard then
                herocard.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                hqzone.Call('click_draw_hero')
            end
        end
        broadcastToAll("Scheme Twist: All heroes in HQ KO'd!")
    else
        broadcastToAll("Scheme Twist: KO one of the hero decks!!",{1,0,0})
        local divdeckzones = {}
        for i=7,11 do
            local deck = Global.Call('get_decks_and_cards_from_zone',allTopBoardGUIDS[i])[1]
            if deck then
                table.insert(divdeckzones,getObjectFromGUID(allTopBoardGUIDS[i]))
            end
        end

        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = table.clone(divdeckzones),
            pos = "Stay",
            label = "KO",
            tooltip = "KO this hero deck.",
            trigger_function = 'koThisHeroDeck',
            args = "self",
            isZone = true,
            fsourceguid = self.guid})
    end
    return twistsresolved
end