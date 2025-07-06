local KVP = {
    transactions = {},
}
KVP.__index = KVP

function KVP:startTransaction(key)
    local transactionId = GenerateId('numeric')

    local counter = 0
    while self.transactions[transactionId] ~= nil and counter < 5 do
        transactionId = GenerateId('numeric')
        counter += 1
    end

    if counter == 5 then
        error('KVP - Unable to generate an unused ID for startTransaction !', 0)
    end

    self.transactions[transactionId] = {
        key = key,
        values = {},
    }

    return transactionId
end

function KVP:addToTransaction(transactionId, key, value)
    if type(transactionId) ~= "number" or not self.transactions[transactionId] then
        error(string.format(
            'KVP - Unable to add transaction, transactionId is %s !',
            type(transactionId) ~= "number" and "missing" or "not registered"
        ), 0)
        return
    end

    self.transactions[transactionId].values[key] = value
end

function KVP:saveTransaction(transactionId)
    local data = self.transactions[transactionId]

    if not data then
        warn(string.format('KVP No transaction data found for id: %s', transactionId))
        return
    end

    local key, values = data.key, data.values

    SetResourceKvp(key, json.encode(values))

    self.transactions[transactionId] = nil
end
