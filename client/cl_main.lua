local HUD = {
    initialized = false,
    dataThread = nil,
    temperatureThread = nil,
    lastData = {
        money = 0,
        gold = 0,
        rol = 0,
        id = 0,
        temp = 0
    }
}

local function Debug(message)
    if Config.DevMode then
        print('^3[' .. GetCurrentResourceName() .. ']^7 ' .. tostring(message))
    end
end

local function getTemperature()
    local playerPed = PlayerPedId()
    if not DoesEntityExist(playerPed) then return 0 end
    
    local coords = GetEntityCoords(playerPed)
    return math.floor(GetTemperatureAtCoords(coords.x, coords.y, coords.z))
end

local function sendConfigToNUI()
    SendNUIMessage({
        action = 'setConfig',
        config = {
            money = Config.Setup.money,
            gold = Config.Setup.gold,
            rol = Config.Setup.rol,
            id = Config.Setup.id,
            temperature = Config.Setup.temperature,
            name = Config.Setup.name,
            desc = Config.Setup.desc,
            logo = Config.Setup.logo
        }
    })
end

local function updatePlayerData(data)
    local changed = false
    local updateData = { action = 'updateData' }
    
    if data.money and data.money ~= HUD.lastData.money then
        updateData.money = data.money
        HUD.lastData.money = data.money
        changed = true
    end
    
    if data.gold and data.gold ~= HUD.lastData.gold then
        updateData.gold = data.gold
        HUD.lastData.gold = data.gold
        changed = true
    end
    
    if data.rol and data.rol ~= HUD.lastData.rol then
        updateData.rol = data.rol
        HUD.lastData.rol = data.rol
        changed = true
    end
    
    if data.id and data.id ~= HUD.lastData.id then
        updateData.id = data.id
        HUD.lastData.id = data.id
        changed = true
    end
    
    if changed then
        SendNUIMessage(updateData)
        Debug('Data updated')
    end
end

local function fetchPlayerData()
    TriggerServerEvent('spooni_hud:requestData')
end

local function startDataUpdateThread()
    if HUD.dataThread then return end
    
    HUD.dataThread = true
    Citizen.CreateThread(function()
        while HUD.initialized do
            fetchPlayerData()
            Citizen.Wait(Config.UpdateIntervals.playerData)
        end
        HUD.dataThread = nil
    end)
end

local function startTemperatureThread()
    if HUD.temperatureThread then return end
    
    HUD.temperatureThread = true
    Citizen.CreateThread(function()
        while HUD.initialized do
            local temp = getTemperature()
            
            if temp ~= HUD.lastData.temp then
                HUD.lastData.temp = temp
                SendNUIMessage({
                    action = 'updateTemp',
                    temp = temp
                })
            end
            
            Citizen.Wait(Config.UpdateIntervals.temperature)
        end
        HUD.temperatureThread = nil
    end)
end

local function initializeHUD()
    if HUD.initialized then
        Debug('HUD already initialized')
        return
    end
    
    HUD.initialized = true
    Debug('Initializing HUD...')
    
    sendConfigToNUI()
    fetchPlayerData()
    startDataUpdateThread()
    
    if Config.Setup.temperature then
        startTemperatureThread()
    end
    
    Debug('HUD initialized successfully')
end

local function shutdownHUD()
    Debug('Shutting down HUD...')
    HUD.initialized = false
    Citizen.Wait(100)
    HUD.dataThread = nil
    HUD.temperatureThread = nil
    Debug('HUD shutdown complete')
end

-- Event handlers
RegisterNetEvent('vorp:SelectedCharacter', function(charid)
    Debug('Character selected: ' .. tostring(charid))
    Citizen.Wait(1000)
    initializeHUD()
end)

RegisterNetEvent('vorp:initCharacter', function()
    Debug('Character initialized')
    Citizen.Wait(1000)
    initializeHUD()
end)

RegisterNetEvent('spooni_hud:receiveData', function(data)
    if data then updatePlayerData(data) end
end)

RegisterNetEvent('spooni_hud:updateClient', function(data)
    if HUD.initialized then updatePlayerData(data) end
end)

RegisterNetEvent('spooni_hud:refresh', function()
    if HUD.initialized then fetchPlayerData() end
end)

-- Commands
RegisterCommand(Config.Setup.commands.toggle, function()
    if HUD.initialized then
        SendNUIMessage({ action = 'toggleHUD' })
    else
        Debug('HUD not initialized')
    end
end, false)

TriggerEvent('chat:addSuggestion', '/' .. Config.Setup.commands.toggle, 'Toggle HUD visibility')

if Config.DevMode then
    RegisterCommand(Config.Setup.commands.dev, function()
        fetchPlayerData()
        Debug('Force refresh')
    end, false)
    
    TriggerEvent('chat:addSuggestion', '/' .. Config.Setup.commands.dev, 'Force HUD refresh')
end

-- Resource lifecycle
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        shutdownHUD()
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    if not HUD.initialized then
        Debug('Auto-init (resource restart)')
        initializeHUD()
    end
end)
