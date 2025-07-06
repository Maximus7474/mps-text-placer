---Generate a random identifier
---@param type 'numeric'|'alpha'|'alphanumeric'
---@param prefix string|nil
---@return string
function GenerateId(type, prefix)
    math.randomseed(os.time() + os.clock())
    local characters
    local length = 16

    if type == "numeric" then
        characters = "0123456789"
    elseif type == "alpha" then
        characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    elseif type == "alphanumeric" then
        characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    else
        error("Invalid type. Use 'numeric', 'alpha', or 'alphanumeric'.")
        return nil ---@diagnostic disable-line: return-type-mismatch
    end

    local id_chars = {}
    for i = 1, length do
        id_chars[i] = characters:sub(math.random(1, #characters), math.random(1, #characters))
    end

    local generated_id = table.concat(id_chars)

    if prefix then
        return prefix .. '-' .. generated_id
    else
        return generated_id
    end
end
