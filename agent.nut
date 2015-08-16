server.log("Turn LED Off: " + http.agenturl() + "?method=SET&identifier=ledState&value=0");
server.log("Turn LED On: " + http.agenturl() + "?method=SET&identifier=ledState&value=1");

reqid <- 0;
requests <- {};
function requestHandler(request, response) {
    server.log("requestHandler: " + request.query)
    try {
        local method = request.query.method;
        local identifier = request.query.identifier;
        local value = request.query.value[0];

        server.log(" method: " + method);
        server.log(" identifier: " + identifier);
        server.log(" value: " + value);

        reqid += 1;
        local req = { reqid=reqid, method=method, identifier=identifier, value=value };
        requests[reqid] <- [ req, response ];
        device.send(method, req);

    } catch(ex) {
        response.send(500, "Internal Server Error: " + ex);
    }
}

function responseHandler(res) {
    local context = delete requests[reqid];
    local req = context[0];
    local response = context[1];

    if (!req) {
        server.log("Response for unknown request: " + res.reqid);
        return;
    }
    if (res.success) {
        response.send(200, res.res);
    } else {
        response.send(500, res.err);
    }

}

device.on("RESPONSE", responseHandler);

function HttpPostWrapper (url, headers, string) {
  local request = http.post(url, headers, string);
  local response = request.sendsync();
  return response;
}


function register(req) {
    server.log("Registering device: " + req)
    local myDevId = imp.configparams.deviceid;
    local url = "http://api.organiq.io/!/register?deviceid=" + myDevId + "&callback=" + http.agenturl();
    local headers = "";

    local request = http.get(url);
    local response = request.sendsync();

    server.log("Got status: " + response.statuscode)
}
device.on("REGISTER", register);

http.onrequest(requestHandler);
