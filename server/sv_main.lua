local VORPcore = exports.vorp_core:GetCore()
local Config = Config or {}

local function Debug(message)
    if Config.DevMode then
        print('^3[' .. GetCurrentResourceName() .. ']^7 ' .. tostring(message))
    end
end

RegisterNetEvent('spooni_hud:requestData', function()
    local src = source
    if not src or src <= 0 then return end
    
    local User = VORPcore.getUser(src)
    if not User then return end
    
    local Character = User.getUsedCharacter
    if not Character then return end
    
    local playerData = {
        money = tonumber(Character.money) or 0,
        gold = tonumber(Character.gold) or 0,
        rol = tonumber(Character.rol) or 0,
        id = src
    }
    
    TriggerClientEvent('spooni_hud:receiveData', src, playerData)
end)

-- Exports for other resources
exports('updatePlayerHUD', function(source, data)
    if source and source > 0 then
        TriggerClientEvent('spooni_hud:updateClient', source, data)
    end
end)

exports('refreshHUD', function(source)
    if source and source > 0 then
        TriggerClientEvent('spooni_hud:refresh', source)
    end
end)

Citizen.CreateThread(function()
    Debug('Server initialized')
end)