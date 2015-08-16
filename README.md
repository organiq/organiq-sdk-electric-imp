# Organiq Software Development Kit for Electric Imp

Organiq is a platform for developing applications that interact with the real world.

The Organiq Software Development Kit (SDK) for Electric Imp contains library code that enables developers to integrate [Electric Imp](http://www.electricimp.com) devices into Organiq applications. This SDK provides Squirrel-language classes designed to work with the Electric Imp programming environment.

### Installation

Electric Imp programming is normally done via a web-based IDE that does permit arbitrary third party libraries to be required. The Organiq SDK is therefore designed for a "copy-and-paste" installation into the IDE.
    
    `organiq.device.nut` - copy the contents of this file into the `Device` part of the IDE.
    `organiq.agent.nut` - copy the contents of this file into the `Agent` part of the IDE.
    
### Quick Peek

Here's a simple Squirrel-language program that exposes an Electric Imp device to Organiq whose `ledState` property is available for read/write access to Organiq applications:

```Squirrel
# This is the `Device` code that runs on the Electric Imp device itself
# include contents of organiq.device.nut, then:

led <- hardware.pin9;         # LED connected to pin 9 (with 220Ohm resistor!)
led.configure(DIGITAL_OUT);

function getLed() { return led.read(); }            # getter
function setLed(ledState) { led.write(ledState); }  # setter

organiq <- Organiq();
organiq.register("ImpBlinker", {
    {"ledState": [getLed, setLed]}
    };
```

There is only one line (other than the Organiq SDK code) that needs to be added to your `Agent` code (the left side of the Electric Imp IDE).

```Squirrel
# This is the `Agent` code that runs in the Electric Imp cloud
# Include contents of organiq.agent.nut, then:

organiq <- Organiq({ apiKeyId="", apiKeySecret="" });
```

Here's a Node.js application that starts the Electric Imp LED blinking from anywhere on the web:

```JavaScript
var organiq = require('organiq');
function startBlinking(device) {
    setInterval(function() { device.toggleLed(); }, 500);
}
organiq.getDevice('ImpBlinker').then(startBlinking);
```

## Documentation

See <http://organiq-electric-imp.readthedocs.org/en/latest/> for documentation on using Organiq with Electric Imp. 



Copyright (c) 2015 Myk Willis & Company, LLC. All Rights Reserved.
