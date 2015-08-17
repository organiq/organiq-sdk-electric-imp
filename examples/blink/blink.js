var organiq = require('organiq');   // npm install organiq
function startBlinking(device) {
    setInterval(function() { device.toggleLed(); }, 500);
}
organiq.getDevice('ImpBlinker').then(startBlinking);
