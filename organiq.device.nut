class Organiq {

    _alias = null;
    _device = null;

    constructor(alias, device) {
        agent.on("__organiq_GET", this.get.bindenv(this));
        agent.on("__organiq_SET", this.set.bindenv(this));
        agent.on("__organiq_INVOKE", this.invoke.bindenv(this));
        agent.on("__organiq_DESCRIBE", this.describe.bindenv(this));
        #agent.on("__organiq_CONFIG", )

        register(alias, device);
    }

    function register(alias, device) {
        _alias = alias;
        _device = device;
        agent.send("__organiq_REGISTER", _alias);

        server.log("Properties: ");
        foreach(index, item in _device.properties) {
            server.log("  " + index + ": " + item);
        }

        server.log("Methods: ");
        foreach(index, item in _device.methods) {
            server.log("  " + index + ": " + item);
        }

        server.log("Events: ");
        foreach(index, item in _device.events) {
            server.log("  " + index + ": " + item);
        }
    }

    function sendSuccessResponse(req, res) {
        local response = { reqid=req.reqid, success=true, res=res };
        agent.send("__organiq_RESPONSE", response)
    }

    function sendErrorResponse(req, err) {
        local response = { reqid=req.reqid, success=false, err=err };
        agent.send("__organiq_RESPONSE", response)
    }


    function get(req) {
        try {
            server.log("[organiq] GET " + req.identifier);
            local f = _device.properties[req.identifier][0];
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
            local f = _device.properties[req.identifier][1];
            f(req.value.tointeger());
            sendSuccessResponse(req, true);
        } catch(ex) {
            sendErrorResponse(req, ex);
        }
    }

    function invoke(req) {
        try {
            server.log("[organiq] INVOKE " + req.identifier + "(" + req.value + ")");
            local f = _device.methods[req.identifier];
            local res = f(req.value);
            server.log("  result: " + res);
            sendSuccessResponse(req, res);
        } catch(ex) {
            sendErrorResponse(req, ex);
        }
    }

    function describe(req) {
        try {
            server.log("[organiq] DESCRIBE ");
            local res = {};
            res.methods <- {}
            foreach (method, _ in _device.methods) {
                res.methods[method] <- { type = "unknown" };
            }
            res.properties <- {}
            foreach (prop, _ in _device.properties) {
                res.properties[prop] <- { type = "unknown" };
            }
            res.events <- {}
            foreach (event, _ in _device.events) {
                res.events[event] <- { type = "unknown" };
            }
            server.log("  result: " + res);
            sendSuccessResponse(req, res);
        } catch(ex) {
            sendErrorResponse(req, ex);
        }
    }
}




//server.log("Device ID: " + hardware.getdeviceid());
//
//led <- hardware.pin9;
//led.configure(DIGITAL_OUT);
//
//function getLed() { return led.read(); }
//function setLed(ledState) { led.write(ledState); }
//
//function toggleLed(x) { led.write(1-led.read()); return led.read(); }
//
//organiq <- Organiq("ImpBlinker", {
//    properties = {
//        ledState = [getLed, setLed]  // property: [getter, setter]
//    },
//    methods = {
//        toggleLed = toggleLed
//    },
//    events = []
//});
