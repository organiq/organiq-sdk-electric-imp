// blink.device.nut

/*
  Note: To run this example from the Electric Imp IDE, you need to paste the
  contents of the `organiq.device.nut` file (included in the Organiq SDK's root
  folder) into this example. The `#require` syntax is not yet supported.
*/

//#require "Organiq.device.nut:0.1.0"   // Not yet supported: See note above.

{ Paste contents of organiq.device.nut here }

led <- hardware.pin9;
led.configure(DIGITAL_OUT);

function getLed() { return led.read(); }
function setLed(ledState) { led.write(ledState); }

function toggleLed() { led.write(1-led.read()); return led.read(); }

organiq <- Organiq("ImpBlinker", {
    properties = {
        ledState = [getLed, setLed]  // property: [getter, setter]
    },
    methods = {
        toggleLed = toggleLed
    },
    events = []
});
