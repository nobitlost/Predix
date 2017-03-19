# Predix

The library allows to integrate your IMP agent code with [GE Predix IoT platform](https://www.predix.io). It uses Predix User Account and Authentication (UAA), Asset and Time Series services [REST API](https://www.predix.io/api).

**To add this library to your project, add** `#require "Predix.class.nut:1.0.0"` **to the top of your agent code.**

Before using this library you need to:
- register an account at the Predix platform
- add UAA, Assets, Time Series services to your account
- create and configure a client using UAA service instance
- obtain URLs of UAA, Assets and Time Series service instances
- obtain Zone-Id identifiers of Assets and Time Series service instances

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
#require "Predix.class.nut:1.0.0"

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

**createAsset(assetType, assetId, assetInfo, callback)** method creates or updates a specified asset.

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
}.bindenv(this));
```

**queryAsset(assetType, assetId, callback)** method checks if a specified asset exists.

If the specified asset exists (*PREDIX_STATUS.SUCCESS* is reported), the asset properties can be found in *response.body* argument of the callback.

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
}.bindenv(this));
```

**deleteAsset(assetType, assetId, callback)** method deletes a specified asset.

If the specified asset does not exist, the method does nothing. *PREDIX_STATUS.SUCCESS* is returned in the callback for the both cases - the asset is successfully deleted or it has not existed.

```squirrel
predix.deleteAsset("my_sensor", "unique_id_1234", function(status, errMessage, response) {
    if (PREDIX_STATUS.SUCCESS == status) {
        // the asset does not exist anymore - continue application logic
    }
    else {
        // log errMessage and response, if any
    }
}.bindenv(this));
```

### Data sending

The library provides **ingestData(assetType, assetId, data, timestamp, callback)** method to send data to the Predix platform using Predix Time Series service.

If the data measurement timestamp is not specified, the library inserts and sends the current timestamp.

```squirrel
data = { "my_data" : "value_100" };

predix.ingestData("my_sensor", "unique_id_1234", data, null, function(status, errMessage, response) {
    if (PREDIX_STATUS.SUCCESS == status) {
        // the data has been sent - continue application logic
    }
    else {
        // log errMessage and response, if any
    }
}.bindenv(this));
```

### Errors processing

All requests to the Predix platform are asynchronous.

Every method that sends a request has an optional callback parameter which is called when the operation is completed, successfully or not.

The callback provides:
- *status* - a status of the operation (success or one of the error types)
- *errMessage* - error details, in case of error
- *response* - response from the Predix platform, if it has been received

There are the following error types provided in *status*:

- *PREDIX_STATUS.LIBRARY_ERROR* - it happens if the library has been wrongly initialized or invalid arguments are passed into the method. Usually it means an issue during an application development, it should be fixed during the application debugging and should not happen after the application deployment. The error details are provided in *errMessage*.

- *PREDIX_STATUS.PREDIX_REQUEST_FAILED* - it's a possible error which may happen during a normal execution of application. Usually it means the application should normally proceed this error as a part of the application logic. The error details are provided in *errMessage* and in *response*.

- *PREDIX_STATUS.PREDIX_UNEXPECTED_RESPONSE* - it means an unexpected behavior of the Predix platform (e.g. a response which does not correspond to the Predix REST API specification). The error details are provided in *errMessage* and in *response*.

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
