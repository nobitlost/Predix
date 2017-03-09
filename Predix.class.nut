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
//         - obtain URLs of UAA, Assets and Time Series service instances
//         - obtain Zone-Id identificators of Assets and Time Series service 
//           instances
//     For more information see Predix Documentation https://www.predix.io/docs
//
//     To instantiate this library you need to have:
//         - UAA service instance URL,
//         - UAA service client id,
//         - UAA service client secret,
//         - Asset service instance URL,
//         - Asset service Zone-Id,
//         - TimeSeries service ingestion URL,
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
//     All requests to Predix platform are made asynchronously.
//     Any method that sends a request has an optional callback parameter.
//     If the callback is provided, it is executed when a response is received
//     and the operation is completed, successfully or not.
//     The callback function has signature:
//         cb(error, response), where
//             error : string
//                 Error message (if the operation has been failed)
//                 or null (no error occured, the operation is successfull).
//             response : table
//                 Response received as a reply from the Predix platform.
//                 It contains the following keys and values:
//                     statuscode : HTTP status code
//                     headers    : table of returned HTTP headers
//                     body       : returned HTTP body decoded from JSON (if any)
//
// Dependencies
//     Promise Library
 
// Predix REST API error messages
const PREDIX_INVALID_REQUEST_ERROR = "Error: Invalid Request";
const PREDIX_INVALID_AUTH_TOKEN_ERROR = "Error: Invalid Authentication Token";
const PREDIX_MISSING_RESOURCE_ERROR = "Error: Resource does not exist";
const PREDIX_PAYLOAD_TOO_LARGE = "Error: Payload Too Large";
const PREDIX_INTERNAL_SERVER_ERROR = "Error: Internal Server Error";
const PREDIX_UNEXPECTED_ERROR = "Error: Unexpected error";

// Internal Predix library constants
const _PREDIX_TOKEN_RENEW_BEFORE_EXPIRY_SEC = 60;

class Predix {
    static VERSION = "1.0.0";

    _uaaUrl = null;
    _clientId = null;
    _clientSecret = null;
    _assetUrl = null;
    _assetZoneId = null;
    _timeSeriesIngestUrl = null;
    _timeSeriesZoneId = null;
    
    _accessToken = null;
    _tokenRenewTime = null; 
    _isHttpTimeSeriesIngest = false;

    // Predix library constructor
    //
    // Parameters:
    //     uaaUrl : string              Predix UAA service instance URL
    //     clientId : string            Id of a client registered in Predix UAA service
    //     clientSecret : string        Predix UAA client secret
    //     assetUrl : string            Predix Asset service instance URL
    //     assetZoneId : string         Predix Zone ID for Asset service
    //     timeSeriesIngestUrl : string Predix Time Series service ingestion URL
    //     timeSeriesZoneId : string    Predix Zone ID for TimeSeries service
    //
    // Returns:                         Predix library object created
    constructor(uaaUrl, clientId, clientSecret, assetUrl, assetZoneId, timeSeriesIngestUrl, timeSeriesZoneId) {
        _uaaUrl = uaaUrl;
        _clientId = clientId;
        _clientSecret = clientSecret;
        _assetUrl = assetUrl;
        _assetZoneId = assetZoneId;
        _timeSeriesIngestUrl = timeSeriesIngestUrl;
        _timeSeriesZoneId = timeSeriesZoneId;

        // check timeSeriesIngestUrl scheme
        local scheme = timeSeriesIngestUrl.slice(0, timeSeriesIngestUrl.find(":"));
        if (scheme == "https" || scheme == "http") {
            _isHttpTimeSeriesIngest = true;
        }
    }

    // Creates or updates custom asset for the EI device in Predix IoT platform 
    // using Predix Asset service.
    // The asset is uniquely identified by a pair <assetType>, <assetId>.
    // If the asset with this identifier does not exist, it is created.
    // The created asset will be available at <_assetUrl>/<assetType>/<assetId> URL.
    // If the asset with this identifier already exists, it is updated by the new
    // provided properties. All old properties are deleted.
    //
    // Parameters:
    //     assetType : string        Predix asset type, any alphanumeric value 
    //                               with optional underscores or dashes
    //     assetId : string          Id of asset to be created in Predix, any 
    //                               alphanumeric value with optional underscores
    //                               or dashes
    //     assetInfo : table         Asset properties of any format.
    //                               Any property of the device can be specified
    //                               in the format {"<property_name>" : <property_value>, ...}.
    //                               assetInfo can be empty.
    //     cb (optional) : function  Function to execute when response received, 
    //                               the exact format is specified above
    //
    // Returns:                      Nothing
    function createAsset(assetType, assetId, assetInfo, cb = null) {
        // check access token, then
        // POST to <_assetUrl>/<assetType>
        _accessCheckPromise().
            then(function(msg) {
                if (!assetInfo) {
                    assetInfo = {};
                }
                assetInfo["uri"] <- format("/%s/%s", assetType, assetId);
                local url = format("%s/%s", _assetUrl, assetType);
                local req = http.post(url, _createHeaders(_assetZoneId), http.jsonencode([assetInfo]));
                req.sendasync(function(resp) {
                    _processResponse(resp, cb);
                }.bindenv(this));
            }.bindenv(this),
            _handleError);
    }
    
    // Queries custom asset from Predix IoT platform. 
    // If the asset doesn't exist, the callback (if provided) is called with 
    // error parameter = PREDIX_MISSING_RESOURCE_ERROR.
    // If the asset exists, the callback (if provided) is called with
    // error parameter = null.
    //
    // Parameters:
    //     assetType : string        Type of the asset
    //     assetId : string          Id of the asset to be queried
    //     cb (optional) : function  Function to execute when response received, 
    //                               the exact format is specified above
    //
    // Returns:                      Nothing
    function queryAsset(assetType, assetId, cb = null) {
        // check access token, then
        // GET to <_assetUrl>/<assetType>/<assetId>
        _accessCheckPromise().
            then(function(msg) {
                local url = format("%s/%s/%s", _assetUrl, assetType, assetId);
                local req = http.get(url, _createHeaders(_assetZoneId));
                req.sendasync(function(resp) {
                    _processResponse(resp, cb);
                }.bindenv(this));
            }.bindenv(this),
            _handleError);
    }
    
    // Deletes custom asset from Predix IoT platform.
    // If the asset doesn't exist, it does nothing and won't pass any error to 
    // the callback.
    //
    // Parameters:
    //     assetType : string        Type of the asset
    //     assetId : string          Id of the asset to be deleted
    //     cb (optional) : function  Function to execute when response received,
    //                               the exact format is specified above
    //
    // Returns:                      Nothing
    function deleteAsset(assetType, assetId, cb = null) {
        // check access token, then
        // DELETE to <_assetUrl>/<assetType>/<assetId>
        _accessCheckPromise().
            then(function(msg) {
                local url = format("%s/%s/%s", _assetUrl, assetType, assetId);
                local req = http.httpdelete(url, _createHeaders(_assetZoneId));
                req.sendasync(function(resp) {
                    _processResponse(resp, cb);
                }.bindenv(this));
            }.bindenv(this),
            _handleError);
    }

    // Ingests data to Predix IoT platform using Predix Time Series service.
    // Every <data_value> from data parameter formatted as {"<data_name>" : "<data_value>", ...}
    // is ingested to Predix Time Series with tag name <assetType>.<assetId>.<data_name>
    //
    // Parameters:
    //     assetType : string        Type of the asset
    //     assetId : string          Id of asset whose data is posted
    //     data : table              Data to be ingested to Predix Time Series,
    //                               table formatted as {"<data_name>" : "<data_value>", ...}
    //     ts (optional) : integer   Data measurement timestamp in seconds since epoch.
    //                               If not specified, the current timestamp is used
    //     cb (optional) : function  Function to execute when response received,
    //                               the exact format is specified above 
    //
    // Returns:                      Nothing
    function ingestData(assetType, assetId, data, ts = null, cb = null) {
        // Predix Time Series service uses WebSocket protocol for data ingestion.
        // The current implementation requires external http-to-websocket proxy that
        // receives HTTP requests from the library and resends them to the Predix 
        // Time Series service through WebSocket
        if (!_isHttpTimeSeriesIngest) {
            _handleError("ingestData failed: non-HTTP TimeSeries ingestion is currently unsupported");
            return;
        }
        // check access token, then
        // POST to <_timeSeriesIngestUrl>
        _accessCheckPromise().
            then(function(msg) {
                if (!ts) {
                    ts = time();
                }
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
                local req = http.post(_timeSeriesIngestUrl, _createHeaders(_timeSeriesZoneId), http.jsonencode(predixData));
                req.sendasync(function(resp) {
                    _processResponse(resp, cb);
                }.bindenv(this));
            }.bindenv(this),
            _handleError);
    }

    // -------------------- PRIVATE METHODS -------------------- //

    // Checks Predix UAA access token and recreates it if needed.
    //
    // Parameters:          None
    //
    // Returns:             Promise that resolves when access token is successfully 
    //                      obtained, or rejects with an error
    function _accessCheckPromise() {
        return Promise(function(resolve, reject) {
            if (_accessToken == null || _tokenRenewTime < time()) {
                // Request new access token
                // POST to <_uaaUrl>/oauth/token
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
                                _tokenRenewTime = time() + resp.body["expires_in"] - _PREDIX_TOKEN_RENEW_BEFORE_EXPIRY_SEC;
                                return resolve("Access token created successfully");
                            }
                            return reject("Unexpected response from Predix User Account and Authentication service");
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
    //     predixZoneId : string     Predix Zone ID of the service instance
    //
    // Returns:                      request header table
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
    //     resp : table              The response object from Predix
    //     cb : function             The callback function passed into the request 
    //                               or null, the exact format is specified above
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
    //     statusCode : integer      status code from response
    //
    // Returns:                      the corresponding error message
    function _getError(statusCode) {
        local err = null;
        switch (statusCode) {
            case 400:
                err = PREDIX_INVALID_REQUEST_ERROR;
                break;
            case 401:
                err = PREDIX_INVALID_AUTH_TOKEN_ERROR;
                break;
            case 404:
                err = PREDIX_MISSING_RESOURCE_ERROR;
                break;
            case 413:
                err = PREDIX_PAYLOAD_TOO_LARGE;
                break;
            case 500:
                err = PREDIX_INTERNAL_SERVER_ERROR;
                break;
            default:
                err = format("Status Code: %i, %s", statusCode, PREDIX_UNEXPECTED_ERROR);
        }
        return err;
    }

    // Handles an error occurred during the library methods execution
    //
    // Parameters:
    //     errMessage : string       the error message occurred
    //
    // Returns:                      Nothing
    function _handleError(errMessage) {
        server.error("[Predix] " + errMessage);
    }
}
