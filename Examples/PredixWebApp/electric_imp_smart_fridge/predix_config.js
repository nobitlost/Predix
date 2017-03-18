// Copyright (c) 2017 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

'use strict';

// This module reads config settings from Predix VCAP environment variables

// required modules
const URL = require('url');

var config = {
    uaaUrl : null,
    uaaHostName : null,
    uaaClientId : null,
    uaaClientSecret : null,
    assetHostName : null,
    assetZoneId : null,
    timeSeriesQueryHostName : null,
    timeSeriesZoneId : null,
    timeSeriesIngestUrl : null,
    initializationError : null
};

readEnvVars();

// Reads config settings from Predix VCAP environment variables
function readEnvVars() {
    try {
        var services = JSON.parse(process.env["VCAP_SERVICES"]);
        var uaa = services['predix-uaa'];
        config.uaaUrl = uaa[0].credentials.uri;
        config.uaaHostName = URL.parse(config.uaaUrl).hostname;
        config.uaaClientId = process.env.clientId;
        config.uaaClientSecret = process.env.clientSecret;
        var asset = services['predix-asset'][0].credentials;
        config.assetHostName = URL.parse(asset.uri).hostname;
        config.assetZoneId = asset.zone['http-header-value'];
        var timeSeriesQuery = services['predix-timeseries'][0].credentials.query;
        config.timeSeriesQueryHostName = URL.parse(timeSeriesQuery.uri).hostname;
        config.timeSeriesZoneId = timeSeriesQuery['zone-http-header-value'];
        config.timeSeriesIngestUrl = services['predix-timeseries'][0].credentials.ingest.uri;
    }
    catch (e) {
        config.initializationError = e.message;
        console.error(config.initializationError);
    }
}

module.exports = config;

