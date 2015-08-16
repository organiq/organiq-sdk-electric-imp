server.log("Turn LED Off: " + http.agenturl() + "?method=SET&property=ledState&value=0");
server.log("Turn LED On: " + http.agenturl() + "?method=SET&property=ledState&value=1");


function requestHandler(request, response) {
    try {
        local method = request.query.method;
        local property = request.query.property;
        local value = request.query.value;

        local req = { method=method, property=property, value=value };
        device.send(method, req);
        response.send(200, "OK");
    } catch(ex) {
        response.send(500, "Internal Server Error: " + ex);
    }
}

function HttpPostWrapper (url, headers, string) {
  local request = http.post(url, headers, string);
  local response = request.sendsync();
  return response;
}


function register() {
    url = "http://api.organiq.io/dapi/register";
    local myDevId = imp.configparams.deviceid;
    headers = "";

    string = "{ agentUrl: " + http.agenturl() + "}";
    response = HttpPostWrapper(url, headers, string);
}
http.onrequest(requestHandler);
