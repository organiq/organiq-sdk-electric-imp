class Organiq {

    deviceid = null;
    device = null;

    constructor(device_) {
        deviceid = hardware.getdeviceid();
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

    function sendSuccessResponse(req, res) {
        local response = { reqid=req.reqid, success=true, res=res };
        agent.send("RESPONSE", response)
    }

    function sendErrorResponse(req, err) {
        local response = { reqid=req.reqid, success=false, err=err };
        agent.send("RESPONSE", response)
    }


    function get(req) {
        try {
            server.log("[organiq] GET " + req.identifier);
            local f = device.properties[req.identifier][0];
            local res = f();
            server.log("  result: " + res);
            sendSuccessResponse(req, res);
        } catch(ex) {
            sendErrorResponse(req, ex);
        }
    }

    function set(req) {
        try {
            server.log("[organiq] SET " + req.identifier + "=" + req.value);
            local f = device.properties[req.identifier][1];
            f(req.value.tointeger());
            sendSuccessResponse(req, true);
        } catch(ex) {
            sendErrorResponse(req, ex);
        }
    }

    function invoke(req) {
        try {
            server.log("[organiq] INVOKE " + req.property + "(" + req.value + ")");
            local f = device.methods[req.identifier][0];
            local res = f(req.value);
            server.log("  result: " + res);
            sendSuccessResponse(req, res);
        } catch(ex) {
            sendErrorResponse(req, ex);
        }
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
