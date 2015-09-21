/**
 * Example application that uses Organiq to interact with an Electric Imp device.
 *
 * $ npm install -g organiq # install Organiq SDK for JavaScript
 * $ organiq register       # register an account with Organiq (one time)
 * $ organiq generate-api-key --global  # create and save API key
 * $ npm init               # create organiq.json
 * $ node blink.js
 *
 */
var organiq = require('organiq');   // npm install organiq
function startBlinking(device) {
    setInterval(function() { device.toggleLed(); }, 500);
}
organiq.getDevice('ImpBlinker').then(startBlinking);
