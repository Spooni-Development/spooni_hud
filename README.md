# 💻 HUD
Documentation relating to the spooni_hud.

## 1. Installation
spooni_hud works only with VORP. 

To install spooni_hud:
- Download the resource
  - On [Github](https://github.com/Spooni-Development/spooni_hud)
- Drag and drop the resource into your resources folder
  - `spooni_hud`
- Add this ensure in your server.cfg
  ```
    ensure spooni_hud
  ```
- Now you can configure and translate the script as you like
  - `config.lua`
- At the end, restart the server

If you have any problems, you can always open a ticket in the [Spooni Discord](https://discord.gg/spooni).

## 2. Usage
The HUD automatically displays when you select a character. It shows your money, gold, role tokens, player ID, and current temperature in real-time.

## 3. For developers

:::details Config.lua
```lua
Config = {}

Config.DevMode = false

Config.UpdateIntervals = {
    temperature = 5000,
    playerData = 1000,
}

Config.Setup = {
    money = true,
    gold = true,
    rol = true,
    id = true,
    temperature = true,
    logo = true,
    name = true,
    desc = true,
    
    commands = {
        toggle = 'toggleHUD',
        dev = 'updateHUD',
    },
}
```
:::