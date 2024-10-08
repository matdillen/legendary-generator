MIN_VALUE = 0
MAX_VALUE = 999
val = 0

function onload()   
    setupGUID = Global.Call('returnVar',"setupGUID")
    
    self.createButton({
      label=val,
      click_function="add_subtract",
      tooltip="Add or remove a shard.",
      function_owner=self,
      position={0,1,0},
      height=1400,
      width=1600,
      font_size = 1200, 
        font_color= "Green",
      color = {0,0,0,0.95}
      })
end

function add_subtract(_obj, _color, alt_click)
    local mod = alt_click and -1 or 1
    local limit = nil
    scheme = getObjectFromGUID(setupGUID).Call('returnVar',"scheme")
    if scheme and scheme.getName() == "Unite The Shards" then
        limit = scheme.Call('returnShardLimit')
    end
    if not limit or limit > 0 or mod == -1 then
        local new_value = math.min(math.max(val + mod, MIN_VALUE), MAX_VALUE)
        if val ~= new_value then
            log("Shards for object " .. self.guid .. " changed from " .. val .. " to " .. new_value)
            val = new_value
            updateVal()
            if scheme and scheme.getName() == "Unite The Shards"  then
                scheme.Call('updateShards',self.guid)
            end
        end
    elseif limit then
        broadcastToAll("Shard supply depleted!")
    end
end

function updateVal()
    self.editButton({
        index = 0,
        label = val
        })
end

function resetVal()
    val = 1
    updateVal()
end

function returnVal()
    return val
end