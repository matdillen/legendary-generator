function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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
    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait = params.twistsstacked,
            what = "Cost",
            prefix = "Cost:",
            players = {Player[Turns.turn_color]}})
    local boost = 0
    if players[1] then
        boost = params.twistsstacked
    end
    if params.object.hasTag("Villain") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object, 
            label = "+" .. boost,
            id="kungfuscheme",
            tooltip = "This Villain has Circle of Kung Fu equal to the number of twists stacked (" .. params.twistsstacked .. ").",
            zoneguid = params.zoneguid})
    end
    local mmZone = getObjectFromGUID(mmZoneGUID)
    local masterminds = table.clone(mmZone.Call('returnVar',"masterminds"))
    for _,m in pairs(masterminds) do
        if boost < 8 and m == "Immortal Emperor Zheng-Zhu" then
            boost = 0
        end
        mmZone.Call('mmButtons',
            {mmname = m,
            checkvalue = 1,
            label = "+" .. boost,
            tooltip = "This Mastermind has Circle of Kung Fu equal to the number of twists stacked (" .. params.twistsstacked .. ").",
            f = "mm",
            id = "kungfuscheme"})
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved == 1 then
        setNotes(getNotes() .. "\r\n\r\n[9D02F9][b]Circle of Kung-Fu:[/b][-] 1")
    else
        local notes = getNotes():gsub("Circle of Kung%-Fu:%[/b%]%[%-%] %d+","Circle of Kung-Fu:[/b][-] " .. twistsstacked,1)
        setNotes(notes)
    end
    return nil
end