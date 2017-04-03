# Electric Imp Smart Refrigerator

Create a connected refrigerator using an Electric Imp and the Predix IoT platform.

You will use an Electric Imp impExplorer&trade; Kit to collect temperature, humidity and light sensor data. This data will be analyzed to determine if your refrigerator compressor is working properly and to track if your refrigerator door has been left open.  Upload data to the Predix IoT platform to monitor and visualize your refrigerator in real time.


## Overview

Skill Level: Advanced

Below are detailed steps that show you how to connect an imp-enabled device containg environmental sensors to the Predix Platform in order to visualize and monitor your refrigerator in real time.

## Ingredients

### General
  - Your WiFi network name and password
  - A smartphone (iOS or Android)
  - A computer with a web browser

### Accounts
  - An [Electric Imp developer account](https://ide.electricimp.com/login)
  - A [Predix account](https://www.predix.io/registration/)

### Hardware
  - An Electric Imp [impExplorer Kit](https://store.electricimp.com/collections/featured-products/products/impexplorer-developer-kit?variant=31118866130)
  - 3 AA Batteries (if you want to install the Kit into a fridge)

### Software
 - The Electric Imp mobile app ([iOS](https://itunes.apple.com/us/app/electric-imp/id547133856) or [Android](https://play.google.com/store/apps/details?id=com.electricimp.electricimp))
  - [Agent code](./SmartRefrigerator_Predix.agent.nut)
  - [Device code](./SmartRefrigerator_Predix.device.nut)
  - [Predix web application](./PredixWebApp/electric_imp_smart_fridge) files
  - [Cloud Foundry CLI](https://github.com/cloudfoundry/cli)
  - [CF Predix](https://github.com/PredixDev/cf-predix)

## Prepare Your Smart Fridge

### Step 1 - Configure your Predix Account and Web Application

#### Predix account configuration

- Open [Predix IoT](https://www.predix.io/) in your web browser.
- Click ‘Sign In’ and log in into your Predix account.
- Click on the default Predix Space, ‘dev’:
![Predix dev](http://i.imgur.com/zrGCrHt.png)
- Click on the ‘Catalog’ button:
![Predix catalog](http://i.imgur.com/8YgvOGa.png)
- Scroll to the ‘Security’ section and click on the ‘User Account and Authentication’ (UAA) service:
![Predix UAA](http://i.imgur.com/nylhU7v.png)
- Scroll to the bottom of the page to the ‘Free’ plan and click on ‘Subscribe’:
![Predix UAA Subscribe](http://i.imgur.com/DjDAkOk.png)
- Choose your predix account login from the ‘Org’ drop-down list.
- Choose ‘dev’ from the ‘Space’ drop-down list.
- Enter a service name into the ‘Service instance name’ field, eg. "uaa".
- Choose the ‘Free’ from the ‘Service Plan’ drop-down.
- Enter any ‘Admin Client Secret’.
- Click on ‘Create Service’:
![Predix UAA Create](http://i.imgur.com/dagEvXp.png)
- Make sure you make a separate note of your **Admin Client Secret** and your **UUA Service Instance Name**, as these will be used for further Predix account confguration.
- Click on ‘Open Service instance’. You will be redirected to the UAA Service Instance page (usually a new tab):
![Predix UAA Open](http://i.imgur.com/8RK38LL.png)
- Enter your Admin Client Secret to log in to your UAA Service instance.
- Click ‘Manage Clients’:
![Predix UAA Client](http://i.imgur.com/al15wAj.png)
- Click on ‘Create Client’:
![Predix UAA Create Client](http://i.imgur.com/sV4Xcf5.png)
- Enter a Client ID’<a id=client-id>, eg. "client".
- Make sure the ‘client_credentials’ check box is checked.
- Enter and confirm a ‘Client Secret’<a id=client-secret>
- Click on ‘Save’.
- Make sure you make a separate note of the **Client ID** and the **Client Secret**, as these will be used for Predix Web Application configuration and the demo agent code initialization:
![Predix UAA Client Details](http://i.imgur.com/YJVvwEb.png)
- Go back to Predix account page in your web browser (the other Predix tab)

<a id=repeat-asset-steps>

- Click on ‘Back to Space’ and then ‘View Catalog’:
![Predix account view catalog](http://i.imgur.com/A0xn5ZD.png)
- Scroll to the ‘Data Management’ section and click on the ‘Asset’ service:
![Predix asset](http://i.imgur.com/WSG80E6.png)
- Scroll to the bottom of the page and the ‘Free’ plan, and click on ‘Subscribe’.
- Choose your predix account login from ‘Org’ drop-down list.
- Choose ‘dev’ from the ‘Space’ drop-down list.
- Select your UAA service from the ‘User Account & Authentication’ drop-down.
- Enter your a Service Instance Name, eg. "asset".
- Choose ‘Free’ from the ‘Service Plan’ drop-down.
- Click on ‘Create Service’:
![Predix asset create](http://i.imgur.com/LOSi0yz.png)
- Make sure you make a separate note of your **Asset Service instance Name**. This will be used for further Predix account configuration.
  - ****
- [Repeat the previous steps](#repeat-asset-steps) (related to the **Asset** service) only this time, when you scroll to the ‘Data Management’ section, click on the ‘Time Series’ service.
- Make sure you make a separate note of your **Time Series Service instance name**. This will be used for further Predix account configuration.
  - ****

#### Install the Predix web application

The following steps are provided in detail for macOS, but you can use similar instructions from the links below for other operating systems.

- **Install [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads) client**:
  - If the [Homebrew](https://brew.sh/) package manager isn’t installed on your Mac, install it as described [here](https://brew.sh/)
  - in a terminal window run the command:

    `brew install cloudfoundry/tap/cf-cli`

- If your Internet connection requires a proxy server, configure your proxy settings as described in
[Predix Developing through a network proxy](https://www.predix.io/resources/tutorials/tutorial-details.html?tutorial_id=1565).
- **Install [CF Predix](https://github.com/PredixDev/cf-predix)**, a plugin for the Cloud Foundry CLI
  - In a terminal window run the command:

    `cf install-plugin https://github.com/PredixDev/cf-predix/releases/download/1.0.0/predix_osx`

- **Log into the Predix Cloud**:
  - In a terminal window run the command:

    `cf predix`

  - Choose one of the regional Point Of Presence (PoP) locations that your account is set up for. This information can be found in your registration welcome Predix email.
  - Enter the email and password of your Predix account:
  ![CF Predix login](http://i.imgur.com/5HgcTSl.png)
- **Download** [Electric Imp’s Predix web application](./PredixWebApp/electric_imp_smart_fridge) files.
- Open the [web application manifest.yml](./PredixWebApp/electric_imp_smart_fridge/manifest.yml) file in a text editor.
  - In the ‘services’ section, modify the file with the values obtained during the Predix account configuration steps:
    - **UAA Service instance name**
    - **Asset Service instance name**
    - **Time Series Service instance name**
  - In the ‘env’ section, modify the file with the values obtained during the Predix account configuration steps:
    - **Client ID**
    - **Client Secret**
  - In the ‘applications’ section
    - Choose a name for your application and modify the ‘name’ value:
  ![Predix WebApp manifest](http://i.imgur.com/ckBNkxe.png)
- **Launch the Predix Web Application**:
  - In a terminal window, change directory to *electric_imp_smart_fridge* of Electric Imp's Predix SmartRefrigerator sample
  - Run the command:

    `cf push -f manifest.yml`

  - If the command fails with `Server error, status code: 400, error code: 210003, message: The host is taken: ...`
    - Choose another name for your application.
    - Modify `manifest.yml`
    - Run `cf push -f manifest.yml` again.
  ![Predix WebApp install result](http://i.imgur.com/cweRjq5.png)
- When the application launch has completed successfully, run the command below to get your application’s environment variables. The output will be used for further Predix account configuring and the demo agent code initialization.
  - Run the command:

    `cf env <your_web_application_name>`

  - There are five items you need to copy down from the command output:

    1. Your **Asset URL**<a id=asset-url>, can be found in **System-Provided->VCAP_SERVICES->predix-asset->credentials->uri** value
    2. Your **Asset Zone ID**<a id=asset-zone-id>, can be found in **System-Provided->VCAP_SERVICES->predix-asset->credentials->zone->http-header-value**
    ![Predix Asset info](http://i.imgur.com/3voLJqs.png)
    3. Your **Time Series Zone ID**<a id=time-series-zone-id>, can be found in **System-Provided->VCAP_SERVICES->predix-timeseries->credentials->ingest->zone-http-header-value**
    ![Predix TimeSeries info](http://i.imgur.com/eM12iWk.png)
    4. Your **UAA URL**<a id=uaa-url>, can be found in **System-Provided->VCAP_SERVICES->predix-uaa->credentials->uri**
    ![Predix TimeSeries info](http://i.imgur.com/EZHWB8b.png)
    5. Your **Web Application URL**<a id=web-application-url>, can be found in **VCAP_APPLICATION->application_uris**
    ![Predix WebApp URL](http://i.imgur.com/Fj35LbL.png)

- Go back to your the UAA Service instance page in your web browser and choose ‘your client’ (you may need to log back in)
  - In the ‘Authorized Services’ section:
    - Click on the ‘Choose Service’ box and select your Asset Service instance name from the drop-down. Your asset instance should show up below the ‘Choose Service’ box after you select it.
    - Click ‘Choose Service’ again and select your Time Series Service instance name  from the drop-down. Your time series instance should show up below the ‘Choose Service’ box after you select it
    - Click ‘Submit’:<a id=uaa-authorized-services>
    ![Predix UAA client configure](http://i.imgur.com/9QdHglm.png)
  - Find your [Time Series Zone ID](#time-series-zone-id) from the previous step (item c), as you will need this for the next step.
  - Click ‘Edit’ (it’s next to the ‘Client Info’ heading):
  ![Predix UAA client configure](http://i.imgur.com/KY4UQHT.png)
    - In the ‘Scopes’ field:
      - Enter "timeseries.zones.<Time Series Zone ID>.ingest" and press ‘Enter’ on you keyboard:
      ![Predix UAA edit](http://i.imgur.com/i9omNUc.png)
      - Similarly enter "timeseries.zones.<Time Series Zone ID>.query" and press ‘Enter’.
    - In the ‘Authorities’ field:
      - Enter "timeseries.zones.<Time Series Zone ID>.ingest" and press ‘Enter’.
      - Enter "timeseries.zones.<Time Series Zone ID>.query" and press ‘Enter’.
    - Click ‘Save}: <a id=uaa-scopes-authorities>
    ![Predix UAA edit](http://i.imgur.com/S8gzk7Z.png)

- **Relaunch Predix Web Application**:
  - Run the command `cf push -f manifest.yml` in a terminal window.

### Step 2 - Connect your Electric Imp impExlorer Kit to the Internet

#### Set up the hardware

1. Plug the imp001 card into the impExplorer Kit board.
2. Power up your device with the three AA batteries.

![Explorer Kit](http://i.imgur.com/6JssX74.png)

When the imp is first powered on it will blink amber if it has not been used before.

#### Electric Imp BlinkUp&trade;

Use the Electric Imp mobile app to configure your device for Internet access:

1. In the app, log into your Electric Imp account.
2. Enter your WiFi network credentials.
3. Follow the instructions in the app to connect your device using BlinkUp.

When BlinkUp is successful, the imp will blink green and the app will show you the device’s unique ID:

<img src="http://i.imgur.com/rljkSnI.png" width="250">

For more information on BlinkUp, pleasevisit the Electric Imp [Dev Center](https://electricimp.com/docs/gettingstarted/blinkup/).

### Step 3 - Connect your Electric Imp impExplorer Kit to Predix IoT

- In your web browser, log into the [Electric Imp IDE](https://ide.electricimp.com/login) using your Electric Imp account credentials.
- Click the ‘+’ button to create a new model:
![Empty IDE](http://i.imgur.com/Ui7w8eG.png)
- In the dialog, enter the following information:

1. A name for your code model, ie. "Smart Refrigerator".
2. Select the checkbox next to your device ID &mdash; this assigns your device to this code model.
3. Click the ‘Create Model’ button.

- Copy and paste the [Predix Smart Refrigerator agent code](./SmartRefrigerator_Predix.agent.nut) and the [Predix Smart Refrigerator device code](./SmartRefrigerator_Predix.device.nut) into the agent and device code panes:
![IDE code windows](http://i.imgur.com/yiCmQZu.png)

- Scroll to the bottom of the agent code to find the Predix account constants.
  - Enter the following values from Step 1 into the corresponding spaces:
    - [**UAA URL**](#uaa-url)
    - [**Client ID**](#client-id)
    - [**Client secret**](#client-secret)
    - [**Asset URL**](#asset-url)
    - [**Asset Zone ID**](#asset-zone-id)
    - [**Time Series Zone ID**](#time-series-zone-id)
  - For the **TIME_SERIES_INGEST_URL** copy the [**WEB_APPLICATION_URL**](#web-application-url) value prefixed by "https://" and postfixed by "/ingest_data".

  It should look like this:<a id=time-series-ingest-url>

  `const TIME_SERIES_INGEST_URL = "https://electricimp-smart-fridge.run.aws-usw02-pr.ice.predix.io/ingest_data";`

- Click ‘Build and Run’ to save and launch the code:
![IDE with code](http://i.imgur.com/lnoCtKR.png)

Take note of your device ID, as specified in the bottom left corner. It can be useful in the next step.

### Step 4 - Refrigerator Data Visualization

- Open your [**Web Application URL**](#web-application-url) prefixed by "https://" in your web browser.
- Select your device ID from drop-down list and click ‘Sensors Data’.
- On the device page, you can see the current temerature and humidity values, door status and alerts over the past hour:
![Predix Web App](http://i.imgur.com/SU2du1n.png)

### Step 5 - Install the Electric Imp impExlorer Kit in Your Refrigerator

Open your refrigerator and place the impExplorer on a shelf in the door:

![Imp In Fridge](http://i.imgur.com/z5llZBg.png)

### Step 6 - Optional Improvements

Your refrigerator is now connected to the internet. As you begin to gather data for your refrigerator you should adjust the static variables in your device SmartFridgeApp class to further customize your integration.

* Adjust the temperature, humidity and lighting thresholds to optimize for your frigde.
* Adjust the reading and reporting times to optimize power usage.

### Troubleshooting

If you have any problems with Predix Smart Refrigerator agent code execution, try to localize it and check your 
Predix account settings and constants, depending on the error:

- If your Smart Refrigerator demo doesn’t log an "[Agent] Dev created" message, and 
  - fails with error "[Agent] ERROR: Predix request failed with status code: 401":
    - Check the [**CLIENT_ID**](#client-id), [**CLIENT_SECRET**](#client-secret) and [**ASSET_ZONE_ID**](#asset-zone-id) 
      constants values from Predix accout constants section of your agent code.
    - Go back to your ‘UAA Service instance’ page in your web browser (you may need to log back in)
      - Choose your client.
      - Ensure your client contains your Asset service instance name in [‘Authorized Services’](#uaa-authorized-services).

  - fails with error "[Agent] ERROR: Predix request failed with status code: 404":
    - Check the [**ASSET_URL**](#asset-url) and [**UAA_URL**](#uaa-url) constants values from Predix accout constants section of your agent code.

- If your Smart Refrigerator demo logs the "[Agent] Dev created" message but then periodically fails during ingest data execution, and 
  - fails with error "[Agent] ERROR: Predix request failed with status code: 404":
    - Check the [**TIME_SERIES_INGEST_URL**](#time-series-ingest-url) constant value from Predix accout constants section of your agent code.
  - fails with error "[Agent] ERROR: Predix request failed with status code: 400":
    - Check the [**TIME_SERIES_ZONE_ID**](#time-series-zone-id) constant value from Predix accout constants section of your agent code
    - Go back to your **UAA Service instance** page in your web browser (you may need to log back in)
      - Choose your client.
      - Ensure your client contains your Time Series service instance name in [‘Authorized Services’](#uaa-authorized-services).
      - Ensure your client’s [‘Scopes’ and ‘Authorities’](#uaa-scopes-authorities) sections contain valid values, ie. `timeseries.zones.<Time Series Zone ID>.ingest`.

If you have any problems with the web application:
  - Try to relaunch the web application using the terminal command `cf push -f manifest.yml`
  - If the web application fails with an "HTTP request failed with status ..." error:
    - Check the `manifest.yml` [**clientId**](#client-id) and [**clientSecret**](#client-secret) parameters.
    - Go back to your UAA Service instance page in your web browser (you may need to log back in), then:
      - Choose your client.
      - Ensure your client contains Asset and Time Series service instance names in [‘Authorized Services’](#uaa-authorized-services).
      - Ensure your client [‘Scopes’ and ‘Authorities’](#uaa-scopes-authorities) contain valid values, ie. `timeseries.zones.<Time Series Zone ID>.query`.

After making any Predix account modification, relaunch the web application using the terminal command 

`cf push -f manifest.yml`

## License

The Predix library is licensed under the [MIT License](../LICENSE).
