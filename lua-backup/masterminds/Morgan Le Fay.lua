function onLoad()
    mmname = "Morgan Le Fay"
    
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "discardguids"
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

function setupMM()
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = 1,
        label = "*",
        tooltip="Chivalrous Duel: Attack Morgan only with the power of a single hero.",
        id = "chivalrousduel",
        f = 'updatePower'})
end

function gainCrapCard(params)
    params.obj.setPositionSmooth(dest[params.player_clicker_color])
    if mplayers[1] then
        local player = table.remove(mplayers,1)
        Wait.time(
            function() 
                morganWounds(player.color)
                broadcastToColor("Choose a starter hero or wound to gain from the KO pile.",player.color,player.color)
            end,1)
    end
end

function morganWounds(color)
    dest[color] = getObjectFromGUID(discardguids[color]).getPosition()
    dest[color].y = dest[color].y + 3
    local kopilecontent = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
    local kodguids = {}
    if kopilecontent[1] and kopilecontent[1].tag == "Deck" then
        for _,c in pairs(kopilecontent[1].getObjects()) do
            for _,tag in pairs(c.tags) do
                if tag == "Starter" or (tag == "Wound" and epicness == false) then
                    table.insert(kodguids,c.guid)
                    break
                end
            end
        end
        if kodguids[1] and not kodguids[2] then
            kopilecontent[1].takeObject({position = dest[color],
                flip = false,
                smooth = true,
                guid = kodguids[1]})
        elseif kodguids[1] and kodguids[2] then
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = color,
                pile = kopilecontent[1],
                guids = kodguids,
                resolve_function = 'gainCrapCard',
                args = "self",
                fsourceguid = self.guid,
                tooltip = "Gain this card.",
                label = "Gain"})
        end
    elseif kopilecontent[1] then
        if kopilecontent[1].hasTag("Starter") or (kopilecontent[1].hasTag("Wound") and epicness == false) then
            kopilecontent[1].setPositionSmooth(dest[color])
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    epicness = params.epicness

    mplayers = nil
    dest = {}
    if epicness then
        broadcastToAll("Master Strike: Each player in turn gains a Wound, then gains a 0-cost Hero from the KO pile.")
        mplayers = Player.getPlayers()
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    else
        mplayers = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Red")
        broadcastToAll("Master Strike: Each player in turn reveals a Red Hero or gains a 0-cost Hero or Wound from the KO pile.")
    end
    if mplayers[1] then
        local player = table.remove(mplayers,1)
        morganWounds(player.color)
        broadcastToColor("Choose a starter hero or wound to gain from the KO pile.",player.color,player.color)
    end
    return strikesresolved
end