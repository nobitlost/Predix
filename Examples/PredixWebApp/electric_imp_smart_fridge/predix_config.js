// MIT License
//
// Copyright 2017 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

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

