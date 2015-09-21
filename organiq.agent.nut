class Organiq {
  _reqid = 0;
  _requests = {};

  static version = [0, 1, 1];
  static validRequestMethods = ["GET", "SET", "INVOKE"];

  _apiRoot = "https://dpi.organiq.io/";
  _apiKeyId = "";
  _apiKeySecret = "";
  _nextRequestHandler = null;

  constructor(options = {}) {
    if ("apiRoot" in options) { _apiRoot = options.apiRoot; }
    if ("apiKeyId" in options) { _apiKeyId = options.apiKeyId; }
    if ("apiKeySecret" in options) { _apiKeySecret = options.apiKeySecret; }
    if ("nextRequestHandler" in options) { _nextRequestHandler = options.nextRequestHandler; }

    http.onrequest(requestHandler.bindenv(this));
    device.on("__organiq_REGISTER", register.bindenv(this));
    device.on("__organiq_RESPONSE", responseHandler.bindenv(this));
  }

  function requestHandler(request, response) {
    server.log("path: " + request.path)
    if (request.path != "/organiq") {
      if (_nextRequestHandler != null) {
        return _nextRequestHandler(request, response);
      } else {
        return response.send(404, "Not Found");
      }
    }

    try {
      local method = request.query.method;
      local identifier = ("identifier" in request.query) ? request.query.identifier : null;
      local value = ("value" in request.query) ? request.query.value[0] : null;

      server.log("Organiq Request Handler");
      server.log(" method: " + method);
      server.log(" identifier: " + identifier);
      server.log(" value: " + value);

      _reqid += 1;
      local req = { reqid=_reqid, method=method,
        identifier=identifier, value=value };
      _requests[_reqid] <- [req, response];
      device.send("__organiq_" + method, req);
    } catch(ex) {
      response.send(500, "Internal Server Error: " + ex);
    }
  }

  function responseHandler(res) {
    local context = delete _requests[res.reqid];
    if (!context) {
      server.log("Response for unknown request (timed out?): " + res.reqid);
    }
    local req = context[0];
    local response = context[1];

    if (res.success) {
      response.send(200, http.jsonencode(res.res));
    } else {
      response.send(500, http.jsonencode(res.err));
    }
  }

  function activate(alias) {
    server.log("Activating device with alias: " + alias);

    local url = _apiRoot + "!/activate?alias=" + alias;
    local headers = {
      "Authorization" : "Basic " + http.base64encode(_apiKeyId + ":" + _apiKeySecret)
    };

    local request = http.get(url, headers);
    local response = request.sendsync();

    if (response.statuscode != 200) {
      server.log("Activate failed: " + response.statuscode + " " + response.body);
      return null;
    }

    local data = http.jsondecode(response.body);

    return data["deviceid"]
  }

  function register(alias) {
  #local myDevId = imp.configparams.deviceid;
    local deviceid = activate(alias);
    if (!deviceid) {
      server.log("Failed to register device.");
      return;
    }

    local callback = http.agenturl() + "/organiq";
    local url = _apiRoot + "!/register?deviceid=" + deviceid + "&callback=" + callback;
    local headers = {
      "Authorization" : "Basic " + http.base64encode(_apiKeyId + ":" + _apiKeySecret)
    };

    server.log("Registering device: '" + deviceid + "' at callback " + callback);

    local request = http.get(url, headers);
    local response = request.sendsync();

    server.log("Got status: " + response.statuscode)
  }
}

// Supply your API key id and secret here:
// organiq <- Organiq({apiKeyId = "", apiKeySecret = ""});