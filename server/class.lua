local TextObject = {}
TextObject.__index = TextObject

Objects = {}

setmetatable(Objects, {
	__call = function(self, id)
		return Objects[id]
	end
})

function Objects.new(id, data) ---@diagnostic disable-line duplicate-set-field
    local self = {
        id = id,
        text = data.text,
        coords = data.coords,
        bucket = data?.bucket or 0,
        expiry = data?.expiry or false,
        zone = data.zone,
    }

    local instance = setmetatable(self, TextObject)

    Objects[id] = instance
    return instance
end

function Objects.remove(id) ---@diagnostic disable-line duplicate-set-field
    Objects[id] = nil
end

function TextObject:save(transactionId)
    if self.expiry or not transactionId then return end

    local data = {
        id = self.id,
        text = self.text,
        coords = self.coords,
        bucket = self.bucket,
        expiry = false,
        zone = self.zone,
    }

    KVP:addToTransaction(transactionId, self.id, data)
end