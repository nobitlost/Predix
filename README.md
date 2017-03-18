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

### Creation an initialization

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
