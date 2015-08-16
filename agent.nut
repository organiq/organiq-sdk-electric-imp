server.log("Turn LED Off: " + http.agenturl() + "?method=SET&identifier=ledState&value=0");
server.log("Turn LED On: " + http.agenturl() + "?method=SET&identifier=ledState&value=1");

reqid <- 0;
requests <- {};
function requestHandler(request, response) {
    try {
        local method = request.query.method;
        local identifier = request.query.identifier;
        local value = request.query.value;

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
    local url = "http://api.organiq.io/dapi/register";
    local myDevId = imp.configparams.deviceid;
    local headers = "";

#    string = "{ agentUrl: " + http.agenturl() + "}";
#    response = HttpPostWrapper(url, headers, string);
}
device.on("REGISTER", register);

http.onrequest(requestHandler);
