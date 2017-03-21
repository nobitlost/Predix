// Copyright (c) 2017 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

const UAA_URL                   = "#{env:PREDIX_UAA_URL}";
const CLIENT_ID                 = "#{env:PREDIX_CLIENT_ID}";
const CLIENT_SECRET             = "#{env:PREDIX_CLIENT_SECRET}";
const ASSET_URL                 = "#{env:PREDIX_ASSET_URL}";
const ASSET_ZONE_ID             = "#{env:PREDIX_ASSET_ZONE_ID}";
const TIME_SERIES_INGEST_URL    = "#{env:PREDIX_TIME_SERIES_INGEST_URL}";
const TIME_SERIES_ZONE_ID       = "#{env:PREDIX_TIME_SERIES_ZONE_ID}";

const ASSET_TYPE = "test_device";
const ASSET_ID = "id_123";

// Test case for ingestData method of Predix library
class IngestDataTestCase extends ImpTestCase {
    _assetInfo = {
        "description" : "test device",
        "location" : "home",
        "sensors" : ["temperature", "humidity"]
    };
    _sensorsData = {
        "temperature" : 23,
        "humidity" : 50
    };
    _predix = null;

    // Initializes Predix library
    function setUp() {
        _predix = Predix(UAA_URL, CLIENT_ID, CLIENT_SECRET, 
            ASSET_URL, ASSET_ZONE_ID, TIME_SERIES_INGEST_URL, TIME_SERIES_ZONE_ID);
    }

    // Tests ingestData
    function testIngestData() {
        _testIngestData(time());
    }

    // Tests ingestData with empty ts parameter
    function testIngestDataWithEmptyTs() {
        _testIngestData(null);
    }

    function _testIngestData(ts) {
        return Promise(function (resolve, reject) {
            _predix.createAsset(ASSET_TYPE, ASSET_ID, _assetInfo, function(status, errMessage, response) {
                if (status != PREDIX_STATUS.SUCCESS) {
                    return reject("createAsset failed:" + errMessage);
                }
                _predix.ingestData(ASSET_TYPE, ASSET_ID, _sensorsData, ts, function(status, errMessage, response) {
                    if (status != PREDIX_STATUS.SUCCESS) {
                        return reject("ingestData failed:" + errMessage);
                    }
                    _predix.deleteAsset(ASSET_TYPE, ASSET_ID, function(status, errMessage, response) {
                        if (status != PREDIX_STATUS.SUCCESS) {
                            return reject("deleteAsset failed:" + errMessage);
                        }
                        return resolve("");
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }
}

