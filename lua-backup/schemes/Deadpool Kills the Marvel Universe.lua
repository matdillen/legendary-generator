function onLoad()   
    local guids1 = {
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local herodeck = Global.Call('get_decks_and_cards_from_zone',"0cd6a9")
    if herodeck[1] then
        if herodeck[1].tag == "Deck" then
            local herodeckcards = herodeck[1].getObjects()
            local deadpoolfound = -1
            --don't do pairs as it doesn't iterate in the right order
            for i = 1,#herodeckcards do
                for _,o in pairs(herodeckcards[i].tags) do
                    if o == "Team:Deadpool" or herodeckcards[i].name == "Deadpool (B)" then
                        deadpoolfound = i
                        break
                    end
                end
                if deadpoolfound > -1 then
                    break
                end
            end
            if deadpoolfound == -1 or deadpoolfound == #herodeckcards then
                herodeck[1].flip()
                herodeck[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
            else
                for i = 1,deadpoolfound do
                    herodeck[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                        flip=true,
                        smooth=true}) 
                end
            end
        else 
            herodeck[1].flip()
            herodeck[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
        end
    else
        broadcastToAll("Hero deck is empty!")
    end
    return twistsresolved
end