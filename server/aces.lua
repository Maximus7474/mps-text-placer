Ace = {}

function Ace:IsAdmin(source)
    local isAdmin = IsPlayerAceAllowed(source, 'text-placer.admin')

    return isAdmin
end
