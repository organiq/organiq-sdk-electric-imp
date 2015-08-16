class Organiq {

    deviceid = null;
    device = null;

    constructor(deviceid_, device_) {
        deviceid = deviceid_;
        device = device_;
    }

    function register() {
        agent.send("REGISTER", hardware.getdeviceid());
        agent.on("GET", this.get.bindenv(this));
        agent.on("SET", this.set.bindenv(this));
        agent.on("INVOKE", this.invoke.bindenv(this));
        #agent.on("DESCRIBE", )
        #agent.on("CONFIG", )

        server.log("Properties: ");
        foreach(index, item in this.device.properties) {
            server.log("  " + index + ": " + item);
        }

        server.log("Methods: ");
        foreach(index, item in this.device.methods) {
            server.log("  " + index + ": " + item);
        }

        server.log("Events: ");
        foreach(index, item in this.device.events) {
            server.log("  " + index + ": " + item);
        }

    }

    function get(req) {
        server.log("[organiq] GET " + req.property);
        local f = device.properties[req.property][0];
        local result = f();
        server.log("  result: " + result);
    }

    function set(req) {
        server.log("[organiq] SET " + req.property + "=" + req.value);
        local f = device.properties[req.property][1];
        local result = f(req.value.tointeger());
        server.log("  result: " + result);
    }

    function invoke(req) {
        server.log("[organiq] INVOKE " + req.property + "(" + req.value + ")");
    }
}




led <- hardware.pin9;

led.configure(DIGITAL_OUT);

function setLed(ledState) {
    server.log("setLed: " + ledState);
    led.write(ledState);
}

function getLed() {
    server.log("getLed");
    return led.read();
}

server.log("Device ID: " + hardware.getdeviceid());

class Device {
    properties = {"ledState": [getLed, setLed]};
    methods = {"setLed":setLed, "getLed":getLed};
    events = ["stateChanged"];
}

local device = Device();
local organiq = Organiq(device);
organiq.register();
