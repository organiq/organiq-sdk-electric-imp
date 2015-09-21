# Organiq Software Development Kit for Electric Imp

Organiq is a platform for developing applications that interact with the real world.

The Organiq Software Development Kit (SDK) for Electric Imp contains library code that enables developers to integrate [Electric Imp](http://www.electricimp.com) devices into Organiq applications. This SDK provides Squirrel-language classes designed to work with the Electric Imp programming environment.


### Prerequisites

Before sing the SDK, you need to get an API key from Organiq. The easiest way to do this is use the Organiq Command Line Interface (CLI) that ships as part of the [Organiq SDK for JavaScript](https://github.com/organiq/organiq-sdk-js). You can install this with:

    $ npm install -g organiq
    
Once installed, you can use the CLI to register an account and get an API key:

    $ organiq register                      # follow the prompts to create account
    $ organiq generate-api-key --global     # saves API key ID and secret to ~/.organiq
    

### Installation

While the Electric Imp programming environment does have a `#require` statement for [including third-party libraries](https://www.electricimp.com/docs/libraries/libraryguide/), it currently supports only [a small number of libraries](https://www.electricimp.com/docs/examples/libraries/) to be included in this manner. The Organiq SDK is therefore designed for a "copy-and-paste" installation into the IDE.
  
Simply copy the contents of the following files into the Electric Imp web IDE above your existing project code and you're all set.

*  [organiq.device.nut](https://raw.githubusercontent.com/organiq/organiq-sdk-electric-imp/master/organiq.device.nut) - copy into the `Device` part of the IDE.
*  [organiq.agent.nut](https://raw.githubusercontent.com/organiq/organiq-sdk-electric-imp/master/organiq.agent.nut) - copy into the `Agent` part of the IDE.

### Quick Peek

Here's a simple Squirrel-language program that allows an LED connected to an Electric Imp to have its state inspected and toggled via Organiq. (The code assumes the LED anode is connected to the Imp's pin9 - don't forget to put a resistor in series with it).

```Squirrel
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
```

There is only one line (other than the Organiq SDK code) that needs to be added to your `Agent` code (the left side of the Electric Imp IDE).

```Squirrel
# This is the `Agent` code that runs in the Electric Imp cloud
# Include contents of organiq.agent.nut, then:

organiq <- Organiq({apiKeyId='<<<APIKEYID>>>', 
                    apiKeySecret='<<<APIKEYSECRET>>>'});
```

Do a "Build and Run" from within the Electric Imp IDE, and then verify that the following URLs work as expected:

    http://api.organiq.io/-/ImpBlinker/ledState=0    # Turn LED off
    http://api.organiq.io/-/ImpBlinker/ledState=1    # Turn LED on
    http://api.organiq.io/-/ImpBlinker/ledState      # Get LED state
    http://api.organiq.io/-/ImpBlinker/toggleLed()   # toggle the LED

And here's a Node.js application that starts the Electric Imp LED blinking from anywhere on the web. (Note that the toggleLed() method is automatically created on the device object based on the type information provided by the device):

```JavaScript
var organiq = require('organiq');   // npm install organiq
function startBlinking(device) {
    setInterval(function() { device.toggleLed(); }, 500);
}
organiq.getDevice('ImpBlinker').then(startBlinking);
```

### Chaining HTTP Request Handlers

The Organiq SDK uses `http.onrequest` to listen to requests. If your project needs to install its own HTTP request handler, you should pass it to the Organiq constructor in the `nextRequestHandler` option to ensure it is called properly.

```Squirrel
function myHttpRequestHandler(req, res) {
...
}

organiq <- Organiq({apiKeyId="YOURAPIKEY", apiKeySecret="YOURAPISECRET",
                    nextRequestHandler=myHttpRequestHandler})
```


Copyright (c) 2015 Organiq, Inc. All Rights Reserved.
