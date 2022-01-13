MIN_VALUE = 0
MAX_VALUE = 999
val = 0

function onload()
    if self.getName() == "" then
        ttText = val
        f_color = {1,1,1,95}
    else
        ttText = val .. "\n" .. self.getName()
        if self.getName() == "Recruit" then
            f_color = {0,0,0,100}
        else
            f_color = {1,1,1,95}
        end
    end

    self.createButton({
      label=tostring(val),
      click_function="add_subtract",
      tooltip=ttText,
      function_owner=self,
      position={0,0.05,-0.2},
      height=600,
      width=1000,
      alignment = 3,
      scale={x=1.5, y=1.5, z=1.5},
      font_size=600,
      font_color=f_color,
      color={0,0,0,0}
      })
      
      self.createInput({
        value = self.getName(), 
        input_function = "editName", 
        tooltip=ttText,
        label = self.getName(),
        function_owner = self, 
        alignment = 3,
        position = {0,0.05,1.7}, 
        width = 1200, 
        height = 1000, 
        font_size = 200, 
        scale={x=1, y=1, z=1},
        font_color= f_color,
        color = {0,0,0,0}
        })

end

function add_subtract(_obj, _color, alt_click,addval)
    local mod =nil
    if addval then
        mod = addval
    else
        mod = alt_click and -1 or 1
    end
    local new_value = math.min(math.max(val + mod, MIN_VALUE), MAX_VALUE)
    if val ~= new_value then
        val = new_value
        updateVal()
    end
end

function addValue(value)
    add_subtract(nil,nil,nil,value)
end

function editName() 
end

function updateVal()
    if self.getName() == "" then
        ttText = val
    else
        ttText = val .. "\n" .. self.getName()
    end
    self.editButton({
        index = 0,
        label = tostring(val),
        tooltip = ttText
        })
end

function reset_val()
    val = 0
    updateVal()
end

function returnVal()
    return val
end