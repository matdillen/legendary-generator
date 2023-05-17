function onLoad()   
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 9 and twistsresolved % 2 == 1 then
        broadcastToColor("Scheme Twist: NEGATIVE PULSE This turn heroes in the HQ cost 1 less and villains/masterminds get -1!",Turns.turn_color,Turns.turn_color)
    elseif twistsresolved < 9 and twistsresolved % 2 == 0 then
        broadcastToColor("Scheme Twist: POSITIVE PULSE This turn heroes in the HQ cost 1 more and villains/masterminds get +1!",Turns.turn_color,Turns.turn_color) 
    elseif twistsresolved == 9 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end
