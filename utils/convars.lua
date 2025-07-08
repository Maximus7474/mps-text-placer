---@class Convars
---@field name string
---@field type 'string'|'integer'|'float'|'boolean'
---@field server boolean is server only
---@field default string|integer|number|boolean
---@field changeHandler number | nil

local convars = {
    {
        name = "draw-distance",
        type = "float",
        server = false,
        default = 10.0,
        changeHandler = nil,
    }, ---@as Convars
}

Convar = {
    values = {}
}

---Get a stored value from the Convar handler
---@param key string
---@return string|number|boolean|nil
function Convar:Get(key)
    local value = self.values[key]

    if value == nil then
        warn(string.format("Convar:Get was called for a non initialized key (%s) !", key))
    end

    return value
end

---Get a stored value from the Convar handler
---@param key string
---@param value string|number|boolean|nil
function Convar:Set(key, value)
    self.values[key] = value
end

---get the current value for a convar
---@param name string
---@param type 'string'|'integer'|'float'|'boolean'
---@param default string|number|boolean
---@return boolean|string|integer|nil
local function GetConvarValue(name, type, default)
    local value
    if type == "string" then
        value = GetConvar(name, default --[[ @as string ]])
    elseif type == "integer" then
        value = GetConvarInt(name, default --[[ @as integer ]])
    elseif type == "float" then
        value = GetConvarFloat(name, default --[[ @as number ]])
    elseif type == "boolean" then
        local default = type(default) == "boolean" and default or default == 1
        value = GetConvarBool(name, default)
    end

    return value
end

-- Setup the convars
for i = 1, #convars do
    local data = convars[i]

    if data.server and not IsDuplicityVersion() then
        goto continue
    end

    local value = GetConvarValue(data.name, data.type, data.default)

    Convar:Set(data.name, value)

    data.changeHandler = AddConvarChangeListener(data.name, function (conVarName)
        local newValue = GetConvarValue(data.name, data.type, data.default)
        Convar:Set(data.value, newValue)
    end)

    ::continue::
end
