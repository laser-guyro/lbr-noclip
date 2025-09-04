local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterServerEvent("noclip:request")
AddEventHandler("noclip:request", function()
    local src = source
    local identifiers = GetPlayerIdentifiers(src)

    for _, id in ipairs(identifiers) do
        for _, allowed in ipairs(Config.AllowedLicenses) do
            if id == allowed then
                TriggerClientEvent("noclip:toggle", src)
                return
            end
        end
    end

    print("[Noclip] Denied: " .. GetPlayerName(src))
end)
