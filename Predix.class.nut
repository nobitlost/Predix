// Copyright (c) 2017 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

// Utility Libraries
#require "promise.class.nut:3.0.0"

// Predix Class:
//     Provides an integration with GE Predix IoT platform using 
//     Predix User Account and Authentication (UAA), Asset and Time Series
//     services REST API.
// 
//     Before using this library you need to:
//         - register an account at the Predix platform
//         - add UAA, Assets, Time Series services to your account
//         - create a client using UAA service instance
//         - deploy a web application to the Predix platform
//         - bind UAA, Assets and Time Series service instances to a web application
//         - obtain Zone-Id identificators of Assets and Time Series service 
//           instances
//     For more information see Predix Documentation https://www.predix.io/docs
//
//     To instantiate this library you need to have:
//         - UAA service instance URL,
//         - UAA service client id,
//         - UAA service client secret,
//         - Asset service Zone-Id,
//         - TimeSeries service Zone-Id.
//
//     EI device or any other "thing" is represented in the Predix platform as an 
//     asset. Every asset is uniquely identified by a pair <assetType>/<assetId>.
//     Usually <assetType> is a type of assets, type of devices, type of "things".
//     It is recommended that you name your <assetType>(s) as related to your
//     application, company, use-case, type of your devices and/or sensors, etc.
//     <assetId> is a unique identifier in the scope of a particular <assetType>.
//     <assetId> may have hierarchical naming structure inside or just to be a
//     unique number (e.g. device id).
//     All library methods which operate with assets and ingest data have
//     <assetType>, <assetId> pair as parameters.
//
//     Predix Time Series service uses WebSocket protocol for data ingestion.
//     The current library implementation uses external http-to-websocket proxy 
//     that receives HTTP requests from the library and resends them to the Predix 
//     Time Series service through WebSocket.
//     The proxy URL should be set using setHttpToWsProxyUrl method before the 
//     first data ingestion.
//
//     All requests to Predix platform are made asynchronously. Any method that 
//     sends a request has an optional callback parameter. If the callback is 
//     provided, it is executed when the response is received and the operation
//     is completed, successfully or not.
//     The callback function has two parameters: error and response.
//     If no error occurs, the error parameter is null.
//     If the error parameter is not null, the operation has been failed.
//
// Dependencies
//     Promise Library
 
class Predix {
    static version = [1, 0, 0];

    // Predix REST API error messages
    static INVALID_REQUEST_ERROR = "Error: Invalid Request";
    static INVALID_AUTH_TOKEN_ERROR = "Error: Invalid Authentication Token";
    static MISSING_RESOURCE_ERROR = "Error: Resource does not exist";
    static PAYLOAD_TOO_LARGE = "Error: Payload Too Large";
    static INTERNAL_SERVER_ERROR = "Error: Internal Server Error";
    static UNEXPECTED_ERROR = "Error: Unexpected error";

    // Predix Asset service URL
    static ASSET_BASE_URL = "https://predix-asset.run.aws-usw02-pr.ice.predix.io";

    static TOKEN_RENEW_BEFORE_EXPIRY_SEC = 60;
    
    _uaaUrl = null;
    _clientId = null;
    _clientSecret = null;
    _assetZoneId = null;
    _timeSeriesZoneId = null;
    _httpToWsProxyUrl = null;
    
    _accessToken = null;
    _tokenRenewTime = null; 

    // Predix library constructor
    //
    // Parameters:
    //     uaaUrl              Predix UAA service instance URL
    //     clientId            Id of a client registered in Predix UAA service
    //     clientSecret        Predix UAA client secret
    //     assetZoneId         Predix Zone ID for Asset service
    //     timeSeriesZoneId    Predix Zone ID for TimeSeries service
    //
    // Returns: Predix library object created
    constructor(uaaUrl, clientId, clientSecret, assetZoneId, timeSeriesZoneId) {
        _uaaUrl = uaaUrl;
        _clientId = clientId;
        _clientSecret = clientSecret;
        _assetZoneId = assetZoneId;
        _timeSeriesZoneId = timeSeriesZoneId;
    }

    // Creates or updates custom asset for the EI device in Predix IoT platform 
    // using Predix Asset service.
    // The asset is uniquely identified by a pair <assetType>, <assetId>.
    // If the asset with this identifier does not exist, it is created.
    // The created asset will be available at ASSET_BASE_URL/<assetType>/<assetId> URL.
    // If the asset with this identifier already exists, it is updated by the new
    // provided properties. All old properties are deleted.
    //
    // Parameters:
    //     assetType        Predix asset type, any alphanumeric value with optional
    //                      underscores or dashes
    //     assetId          Id of asset to be created in Predix, any alphanumeric 
    //                      value with optional underscores or dashes
    //     assetInfo        Asset properties of any format
    //     cb (optional)    Function to execute when response received. 
    //                      It has signature:
    //                          cb(error, response), where
    //                              error       Response error message or null 
    //                                          if no error was encountered
    //                              response    Response received as reply
    //
    // Returns:             Nothing
    function createAsset(assetType, assetId, assetInfo, cb = null) {
        // check access token, then
        // POST to ASSET_BASE_URL/{assetType}
        _checkAccessToken().
            then(function(msg) {
                assetInfo["uri"] <- format("/%s/%s", assetType, assetId);
                local url = format("%s/%s", ASSET_BASE_URL, assetType);
                local req = http.post(url, _createHeaders(_assetZoneId), http.jsonencode([assetInfo]));
                req.sendasync(function(resp) {
                    _processResponse(resp, cb);
                }.bindenv(this));
            }.bindenv(this),
            function(reason) {
                server.error(reason);
            }.bindenv(this));
    }
    
    // Queries custom asset from Predix IoT platform. 
    // If the asset doesn't exist, the callback (if provided) is called with 
    // error parameter = MISSING_RESOURCE_ERROR.
    // If the asset exists, the callback (if provided) is called with
    // error parameter = null.
    //
    // Parameters:
    //     assetType        Type of the asset
    //     assetId          Id of the asset to be queried
    //     cb (optional)    Function to execute when response received. 
    //                      It has signature:
    //                          cb(error, response), where
    //                              error       Response error message or null 
    //                                          if no error was encountered
    //                              response    Response received as reply
    //
    // Returns:             Nothing
    function queryAsset(assetType, assetId, cb = null) {
        // check access token, then
        // GET to ASSET_BASE_URL/{assetType}/{assetId}
        _checkAccessToken().
            then(function(msg) {
                local url = format("%s/%s/%s", ASSET_BASE_URL, assetType, assetId);
                local req = http.get(url, _createHeaders(_assetZoneId));
                req.sendasync(function(resp) {
                    _processResponse(resp, cb);
                }.bindenv(this));
            }.bindenv(this),
            function(reason) {
                server.error(reason);
            }.bindenv(this));
    }
    
    // Deletes custom asset from Predix IoT platform.
    // If the asset doesn't exist, it does nothing and won't pass any error to 
    // the callback.
    //
    // Parameters:
    //     assetType        Type of the asset
    //     assetId          Id of the asset to be deleted
    //     cb (optional)    Function to execute when response received. 
    //                      It has signature:
    //                          cb(error, response), where
    //                              error       Response error message or null 
    //                                          if no error was encountered
    //                              response    Response received as reply
    //
    // Returns:             Nothing
    function deleteAsset(assetType, assetId, cb = null) {
        // check access token, then
        // DELETE to ASSET_BASE_URL/{assetType}/{assetId}
        _checkAccessToken().
            then(function(msg) {
                local url = format("%s/%s/%s", ASSET_BASE_URL, assetType, assetId);
                local req = http.httpdelete(url, _createHeaders(_assetZoneId));
                req.sendasync(function(resp) {
                    _processResponse(resp, cb);
                }.bindenv(this));
            }.bindenv(this),
            function(reason) {
                server.error(reason);
            }.bindenv(this));
    }

    // Ingests data to Predix IoT platform using Predix Time Series service.
    // Every <data_value> from data parameter formatted as {"<data_name>" : "<data_value>", ...}
    // is ingested to Predix Time Series with tag name <assetType>.<assetId>.<data_name>
    //
    // Parameters:
    //     assetType        Type of the asset
    //     assetId          Id of asset whose data is posted
    //     ts               data measurement timestamp in seconds since epoch
    //     data             data to be ingested to Predix Time Series,
    //                      table formatted as {"<data_name>" : "<data_value>", ...}
    //     cb (optional)    Function to execute when response received. 
    //                      It has signature:
    //                          cb(error, response), where
    //                              error       Response error message or null 
    //                                          if no error was encountered
    //                              response    Response received as reply
    //
    // Returns:             Nothing
    function ingestData(assetType, assetId, ts, data, cb = null) {
        // Predix Time Series service uses WebSocket protocol for data ingestion.
        // The current implementation uses external http-to-websocket proxy that
        // receives HTTP requests from the library and resends them to the Predix 
        // Time Series service through WebSocket
        if (_httpToWsProxyUrl == null) {
            server.error("ingestData failed: httpToWsProxyUrl is not set");
            return;
        }
        // check access token, then
        // POST to _httpToWsProxyUrl
        _checkAccessToken().
            then(function(msg) {
                local tsMillis = format("%d000", ts);
                local body = [];
                foreach (sensor, value in data) {
                    local sensorData = {
                        "name" : format("%s.%s.%s", assetType, assetId, sensor),
                        "datapoints" : [[tsMillis, value]],
                    };
                    body.append(sensorData);
                }
                local predixData = {
                    "messageId" : tsMillis,
                    "body" : body
                };
                local req = http.post(_httpToWsProxyUrl, _createHeaders(_timeSeriesZoneId), http.jsonencode(predixData));
                req.sendasync(function(resp) {
                    _processResponse(resp, cb);
                }.bindenv(this));
            }.bindenv(this),
            function(reason) {
                server.error(reason);
            }.bindenv(this));
    }

    // Sets http-to-websocket proxy URL.
    // The current library implementation uses external http-to-websocket proxy 
    // that receives HTTP requests from the library and resends them to the Predix 
    // Time Series service through WebSocket.
    //
    // Parameters:
    //     httpToWsProxyUrl value of _httpToWsProxyUrl property to be set
    //
    // Returns:             Nothing
    function setHttpToWsProxyUrl(httpToWsProxyUrl) {
        _httpToWsProxyUrl = httpToWsProxyUrl;
    }
    
    // -------------------- PRIVATE METHODS -------------------- //

    // Checks Predix UAA access token and recreates it if needed.
    //
    // Parameters:          None
    //
    // Returns:             Promise that resolves when access token is successfully 
    //                      obtained, or rejects with an error
    function _checkAccessToken() {
        return Promise(function(resolve, reject) {
            if (_accessToken == null || _tokenRenewTime < time()) {
                // Request new access token
                // POST to _uaaUrl/oauth/token
                local url = format("%s/oauth/token", _uaaUrl);
                local auth = http.base64encode(format("%s:%s", _clientId, _clientSecret));
                local headers = {
                    "Authorization" : format("Basic %s", auth),
                    "Content-Type" : "application/x-www-form-urlencoded"
                };
                local body = format("client_id=%s&grant_type=client_credentials", _clientId);
                local req = http.post(url, headers, body);
                req.sendasync(function(resp) {
                    _processResponse(resp, function(err, resp) {
                        if (err == null) {
                            if ("access_token" in resp.body && "expires_in" in resp.body) {
                                _accessToken = resp.body["access_token"];
                                _tokenRenewTime = time() + resp.body["expires_in"] - TOKEN_RENEW_BEFORE_EXPIRY_SEC;
                                return resolve("Access token created successfully");
                            }
                            return reject("Predix UAA response is incorrect");
                        }
                        else {
                            // we encountered an error
                            return reject(err);
                        }
                    }.bindenv(this));
                    
                }.bindenv(this));
            }
            else {
                return resolve("Access token is valid");
            }
        }.bindenv(this));
    }
    
    // Creates HTTP headers for Predix Asset and Time Series services requests.
    //
    // Parameters:
    //     predixZoneId     Predix Zone ID of the service instance
    //
    // Returns:             request header table
    function _createHeaders(predixZoneId) {
        return {
            "Authorization" : format("Bearer %s", _accessToken),
            "Predix-Zone-Id" : predixZoneId,
            "Content-Type" : "application/json"
        };
    }

    // Processes responses from Predix services.
    //
    // Parameters:
    //     resp             The response object from Predix
    //     cb               The callback function passed into the request or null.
    //                      It has signature:
    //                          cb(error, response), where
    //                              error       Response error message or null 
    //                                          if no error was encountered
    //                              response    Response received as reply
    //
    // Returns:             Nothing
    function _processResponse(resp, cb) {
        local status = resp.statuscode;
        local err = (status < 200 || status >= 300) ? _getError(status) : null;
        try {
            resp.body = (resp.body == "") ? {} : http.jsondecode(resp.body);
        } catch (e) {
            if (err == null) err = e;
        }

        if (cb) {
            imp.wakeup(0, function() {
                cb(err, resp);
            });            
        }
    }

    // Returns error message by status code.
    //
    // Parameters:
    //     statusCode       status code from response
    //
    // Returns:             the corresponding error message
    function _getError(statusCode) {
        local err = null;
        switch (statusCode) {
            case 400:
                err = INVALID_REQUEST_ERROR;
                break;
            case 401:
                err = INVALID_AUTH_TOKEN_ERROR;
                break;
            case 404:
                err = MISSING_RESOURCE_ERROR;
                break;
            case 413:
                err = PAYLOAD_TOO_LARGE;
                break;
            case 500:
                err = INTERNAL_SERVER_ERROR;
                break;
            default:
                err = format("Status Code: %i, %s", statusCode, UNEXPECTED_ERROR);
        }
        return err;
    }
}
