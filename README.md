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

The current version of the library accepts only *http* or *https* Time Series service ingestion URL.

Please check if the latest Predix platform supports data ingestion over *http* or *https* protocols.

If not (e.g. Time Series service uses only WebSocket protocol for data ingestion), you need an external http-to-websocket proxy that receives HTTP(s) requests from the library and resends them to the Predix Time Series service through WebSocket.

### Assets management

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
