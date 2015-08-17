"Hello, World!" with Organiq
----------------------------

This example demonstrates how to expose device functionality for use by remote applications using Organiq. Specifically, it shows how to expose an LED on an Electric Imp microcontroller and manipulate it from a web browser.

While this example just shows using a web browser to toggle the LED, the device can be accessed through any Organiq application.

To run the demo, you'll need an Electric Imp with an LED connected to pin 9 (make sure to put a 220Ohm resistor in series with it). Open the Electric Imp IDE, and paste the contents of `blink.agent.nut` into the `Agent` half of the IDE (normally the left side), and paste the contents of `blink.device.nut` into the `Device` side of the IDE (normally the right side).

Note: Eventually, you should be able to use the `#require` directive to pull in the appropriate Organiq SDK. For now, you'll have to manually copy the contents of `organiq.agent.nut` and `organiq.device.nut` into your Agent and Device code files, respectively.

Once loaded in the IDE, select `Build and Run`. This will register a device named 'ImpBlinker' with Organiq.

You can test that the device is available by hitting URLs like:

    http://api.organiq.io/-/ImpDevice/ledState=1 # turn LED on
    http://api.organiq.io/-/ImpDevice/ledState=0 # turn LED off
    http://api.organiq.io/-/ImpDevice/ledState   # get LED state

