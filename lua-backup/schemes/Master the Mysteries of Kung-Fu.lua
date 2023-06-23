function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved == 1 then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = self,
            label = "Kung Fu: " .. twistsstacked,
            tooltip = "All villains and masterminds have Circle of Kung Fu equal to the number of twists stacked here."})
        setNotes(getNotes() .. "\r\n\r\n[9D02F9][b]Circle of Kung-Fu:[/b][-] 1")
    else
        self.editButton({index=0,label="Kung Fu: " .. twistsstacked})
        local notes = getNotes():gsub("Circle of Kung%-Fu:%[/b%]%[%-%] %d+","Circle of Kung-Fu:[/b][-] " .. twistsstacked,1)
        setNotes(notes)
    end
    return nil
end