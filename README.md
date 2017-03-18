**NOT COMPLETED YET**

# Predix

The library allows to integrate your IMP agent code with [GE Predix IoT platform](https://www.predix.io). It uses Predix User Account and Authentication (UAA), Asset and Time Series services [REST API](https://www.predix.io/api).

**To add this library to your project, add** `#require "predix.class.nut:1.0.0"` **to the top of your agent and/or device code.**

Before using this library you need to:
- register an account at the Predix platform
- add UAA, Assets, Time Series services to your account
- create a client using UAA service instance
- obtain URLs of UAA, Assets and Time Series service instances
- obtain Zone-Id identificators of Assets and Time Series service instances

If you want to manage your connected device(s) and see the data from the device(s) in Predix, you may:
- create a web application
- deploy the web application to the Predix platform
- bind UAA, Assets and Time Series services (and any other Predix services your application uses) to the web application

For more information about Predix platform setup and usage - see [Predix Documentation](https://www.predix.io/docs).

## Library Usage

The library API is specified [here](./Predix.class.nut)

### Creation and initialization

To instantiate this library you need to have:
- UAA service instance URL
- UAA service client id
- UAA service client secret
- Asset service instance URL
- Asset service Zone-Id
- Time Series service ingestion URL
- Time Series service Zone-Id

And pass these initialization data into the constructor.

```squirrel
#require "predix.class.nut:1.0.0"

predix = Predix(<uaaUrl>, <clientId>, <clientSecret>, <assetUrl>, <assetZoneId>, 
                <timeSeriesIngestUrl>, <timeSeriesZoneId>);
```

The constructor does not return any error. If all or part of the initialization data is not correct, it affects the library methods behavior. You receive an appropriate error when the library method cannot be executed due to the wrong initialization.

**Note:**

**The current version of the library accepts only *http* or *https* Time Series service ingestion URL.**

Please check if the latest Predix platform supports data ingestion over *http* or *https* protocols.

If not (e.g. Time Series service uses only WebSocket protocol for data ingestion), you need an external http-to-websocket proxy that receives HTTP(s) requests from the library and resends them to the Predix Time Series service through WebSocket.

### Assets

Your device is represented in the Predix platform as an asset.

#### Assets identification

Every asset is uniquely identified in the scope of your Predix account by a pair *assetType* / *assetId*.

Usually *assetType* is a type of device, type of sensor/actuator, your application or use case name or anything else you want.

*assetId* must be a unique identifier in the scope of a particular *assetType*. It may have an hierarchical naming structure inside or just to be a unique number (e.g. device id).

All library methods which operate with assets and send data have *assetType* / *assetId* pair as parameters.

#### Assets management

The library provides methods to create/update, delete and query assets in the Predix platform using Predix Asset service.

To update or delete an asset or to send data it is not mandatory to create this asset using the library method. Your application may get an identifier of already created asset by an external way.

**createAsset(assetType, assetId, assetInfo, cb)** method creates or updates a specified asset.

If the specified asset does not exist, it is created and initialized by the provided properties (information).
If the specified asset already exists, it is updated by the new provided properties. All old properties are deleted.

```squirrel
info = { "description" : "My test sensor",
         "location" : "My home" };

predix.createAsset("my_sensor", "unique_id_1234", info, function(status, errMessage, response) {
    if (PREDIX_STATUS.SUCCESS == status) {
        // the asset is created/updated - continue application logic
        }
    else {
        // log errMessage and response, if any
    }
};
```

**queryAsset(assetType, assetId, cb)** method checks if a specified asset exists.

*PREDIX_STATUS.PREDIX_REQUEST_FAILED* error code is used to inform that the asset does not exist.

```squirrel
predix.queryAsset("my_sensor", "unique_id_1234", function(status, errMessage, response) {
    if (PREDIX_STATUS.SUCCESS == status) {
        // the asset exists
        }
    else if (PREDIX_STATUS.PREDIX_REQUEST_FAILED == status) {
        // the asset does not exist
        }
    else {
        // unexpected/library error - log errMessage and response, if any
    }
};
```

**deleteAsset(assetType, assetId, cb)** method deletes a specified asset.

If the specified asset does not exist, the method does nothing. *PREDIX_STATUS.SUCCESS* is returned in the callback for the both cases - the asset is successfuly deleted or it has not existed.

```squirrel
predix.deleteAsset("my_sensor", "unique_id_1234", function(status, errMessage, response) {
    if (PREDIX_STATUS.SUCCESS == status) {
        // the asset does not exist anymore - continue application logic
        }
    else {
        // log errMessage and response, if any
    }
};
```

### Data sending

### Errors processing



## Examples

- [Smart Refrigerator demo: agent code](./Examples/SmartRefrigerator_Predix.agent.nut)

## Testing

**TBD**

Repository contains [impUnit](https://github.com/electricimp/impUnit) tests and a configuration for [impTest](https://github.com/electricimp/impTest) tool.

### TL;DR

```bash
cp .imptest .imptest-local
nano .imptest-local # edit device/model
imptest test -c .imptest-local
```

### Running Tests

Tests can be launched with:

```bash
imptest test
```

By default configuration for the testing is read from [.imptest](https://github.com/electricimp/impTest/blob/develop/docs/imptest-spec.md).

To run test with your settings (for example while you are developing), create your copy of **.imptest** file and name it something like **.imptest.local**, then run tests with:

 ```bash
 imptest test -c .imptest.local
 ```

Tests will run with any imp.

## License

The Promise class is licensed under the [MIT License](./LICENSE).
