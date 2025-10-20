(function() {
    'use strict';

    const DOM = {
        hud: null,
        money: null,
        gold: null,
        rol: null,
        id: null,
        temp: null,
        serverName: null,
        serverDesc: null,
        serverLogo: null,
        playerCurrency: null,
        playerStats: null
    };

    const State = {
        config: null,
        lastValues: {
            money: null,
            gold: null,
            rol: null,
            id: null,
            temp: null
        }
    };

    function formatCurrency(value) {
        const ints = Math.trunc(value);
        const decimals = Math.abs(value).toFixed(2).substr(-2);
        const formattedInts = (ints < 0 ? '-' : '') + Math.abs(ints).toString().padStart(2, '0');
        return `${formattedInts}<span class='cents'>${decimals}</span>`;
    }

    function formatNumber(value) {
        return (value < 0 ? '-' : '') + Math.abs(value).toString().padStart(2, '0');
    }

    function applyConfig(config) {
        if (!config || State.config === config) return;
        
        State.config = config;
        
        if (DOM.money) DOM.money.style.display = config.money ? '' : 'none';
        if (DOM.gold) DOM.gold.style.display = config.gold ? '' : 'none';
        if (DOM.rol) DOM.rol.style.display = config.rol ? '' : 'none';
        if (DOM.id) DOM.id.style.display = config.id ? '' : 'none';
        if (DOM.temp) DOM.temp.style.display = config.temperature ? '' : 'none';
        if (DOM.serverName) DOM.serverName.style.display = config.name ? '' : 'none';
        if (DOM.serverDesc) DOM.serverDesc.style.display = config.desc ? '' : 'none';
        if (DOM.serverLogo) DOM.serverLogo.style.display = config.logo ? '' : 'none';
    }

    function updateData(data) {
        if (data.money !== undefined && data.money !== State.lastValues.money) {
            State.lastValues.money = data.money;
            if (DOM.money) {
                DOM.money.innerHTML = `$ ${formatCurrency(data.money)}`;
            }
        }

        if (data.gold !== undefined && data.gold !== State.lastValues.gold) {
            State.lastValues.gold = data.gold;
            if (DOM.gold) {
                DOM.gold.innerHTML = formatCurrency(data.gold);
            }
        }

        if (data.rol !== undefined && data.rol !== State.lastValues.rol) {
            State.lastValues.rol = data.rol;
            if (DOM.rol) {
                DOM.rol.innerHTML = formatNumber(data.rol);
            }
        }

        if (data.id !== undefined && data.id !== State.lastValues.id) {
            State.lastValues.id = data.id;
            if (DOM.id) {
                DOM.id.innerHTML = `ID ${data.id}`;
            }
        }

        if (data.temp !== undefined && data.temp !== State.lastValues.temp) {
            State.lastValues.temp = data.temp;
            if (DOM.temp) {
                DOM.temp.innerHTML = `${data.temp}°C`;
            }
        }
    }

    function toggleHUD() {
        if (!DOM.hud) return;
        
        if (DOM.hud.style.display === 'none') {
            DOM.hud.style.display = '';
            fadeIn(DOM.hud, 300);
        } else {
            fadeOut(DOM.hud, 300);
        }
    }

    function fadeIn(element, duration) {
        element.style.opacity = 0;
        element.style.display = '';
        
        const start = performance.now();
        
        function animate(currentTime) {
            const elapsed = currentTime - start;
            const progress = Math.min(elapsed / duration, 1);
            
            element.style.opacity = progress;
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        }
        
        requestAnimationFrame(animate);
    }

    function fadeOut(element, duration) {
        element.style.opacity = 1;
        
        const start = performance.now();
        
        function animate(currentTime) {
            const elapsed = currentTime - start;
            const progress = Math.min(elapsed / duration, 1);
            
            element.style.opacity = 1 - progress;
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            } else {
                element.style.display = 'none';
            }
        }
        
        requestAnimationFrame(animate);
    }

    function handleMessage(event) {
        const data = event.data;
        
        switch (data.action) {
            case 'setConfig':
                applyConfig(data.config);
                break;
            case 'updateData':
                updateData(data);
                break;
            case 'updateTemp':
                if (data.temp !== undefined) {
                    updateData({ temp: data.temp });
                }
                break;
            case 'toggleHUD':
                toggleHUD();
                break;
        }
    }

    function initializeDOM() {
        DOM.hud = document.getElementById('hud');
        DOM.money = document.getElementById('money');
        DOM.gold = document.getElementById('gold');
        DOM.rol = document.getElementById('rol');
        DOM.id = document.getElementById('id');
        DOM.temp = document.getElementById('temp');
        DOM.serverName = document.getElementById('serverName');
        DOM.serverDesc = document.getElementById('serverDesc');
        DOM.serverLogo = document.getElementById('serverLogo');
        DOM.playerCurrency = document.querySelector('.playerCurrency');
        DOM.playerStats = document.querySelector('.playerStats');
    }

    function initialize() {
        initializeDOM();
        window.addEventListener('message', handleMessage);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize);
    } else {
        initialize();
    }

})();
