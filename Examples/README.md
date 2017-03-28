# Electric Imp Smart Refrigerator

Create a connected refrigerator using an Electric Imp and the Predix IoT platform.

## Overview
Skill Level: Intermediate

Below are detailed steps on how to connect an Electric Imp with environmental sensors to the Predix Platform in order to visualize and monitor your refrigerator in real time.

## Ingredients - what you need

### General
  - Your WIFI *network name* and *password*
  - A smartphone (iOS or Android)
  - A computer with a web browser

### Accounts
  - An [Electric Imp developer account](https://ide.electricimp.com/login)
  - A [Predix account](https://www.predix.io/registration/)

### Hardware
  - An Electric Imp Explorer kit - [purchase here](https://store.electricimp.com/collections/featured-products/products/impexplorer-developer-kit?variant=31118866130)

And if you want to install the board into a fridge:

  - 3 AA Batteries

### Software
 - The Electric Imp BlinkUp app ([iOS](https://itunes.apple.com/us/app/electric-imp/id547133856) or [Android](https://play.google.com/store/apps/details?id=com.electricimp.electricimp))
  - [Agent code](./SmartRefrigerator_Predix.agent.nut)
  - [Device code](./SmartRefrigerator_Predix.device.nut)
  - [Predix web application](./PredixWebApp/electric_imp_smart_fridge) files
  - [Cloud Foundry CLI](https://github.com/cloudfoundry/cli)
  - [CF Predix](https://github.com/PredixDev/cf-predix)

## Step-by-step

### Step 1 - What is demonstrated in this example?
Use an Electric Imp to collect temperature, humidity and light sensor data.  Analyze the sensor data to determine if your refrigerator compressor is working properly and to track if your refrigerator door has been left open.  Upload data to the Predix IoT platform to monitor and visualize your refrigerator in real time.

### Step 2 - Configure Predix account and web application

#### Predix account configuration

- Open [Predix IoT](https://www.predix.io/) page in your web browser
- Click **SIGN IN** and login into your Predix account
- Click on default Predix space **dev**
![Predix dev](http://i.imgur.com/zrGCrHt.png)
- Click on the **Catalog** button
![Predix catalog](http://i.imgur.com/8YgvOGa.png)
- Scroll to the **SECURITY** section and click **User Account and Authentication** (UAA) service
![Predix UAA](http://i.imgur.com/nylhU7v.png)
- Scroll to the bottom and click **Subscribe** on Free plan
![Predix UAA Subscribe](http://i.imgur.com/DjDAkOk.png)
- Choose your predix account login from **Org** drop-down list
- Choose **dev** from **Space** drop-down list
- Enter **Service instance name**, e.g. "uaa"
- Choose **Free** Service plan
- Enter any **Admin client secret**
- Click **Create Service**
![Predix UAA Create](http://i.imgur.com/dagEvXp.png)
- There are 2 items you need to copy down. These will be used for further Predix account configuring.
  - **UAA Service instance name**
  - **Admin client secret**
- Click **Open Service instance**. You will be redirected to **UAA Service instance** page (usually a new tab).
![Predix UAA Open](http://i.imgur.com/8RK38LL.png)
- Enter **Admin client secret** to login to your UAA Service instance
- Click **Manage Clients**
![Predix UAA Client](http://i.imgur.com/al15wAj.png)
- Click **+ Create Client**
![Predix UAA Create Client](http://i.imgur.com/sV4Xcf5.png)
- Enter **Client ID**<a id=client-id>, e.g. "client"
- Make sure **client_credentials** check box is checked
- Enter and confirm **Client Secret**<a id=client-secret>
- Click **Save**
- There are 2 items you need to copy down. These will be used for Predix Web Application configuring and the demo agent code initialization.
  - **Client ID**
  - **Client Secret**
![Predix UAA Client Details](http://i.imgur.com/YJVvwEb.png)
- Go back to Predix account page in your web browser (the other Predix tab)
- Click **Back to Space** and **View Catalog**
![Predix account view catalog](http://i.imgur.com/A0xn5ZD.png)
- Scroll to the **DATA MANAGEMENT** section and click **Asset** service
![Predix asset](http://i.imgur.com/WSG80E6.png)

<a id=repeat-asset-steps>

- Scroll to the bottom and click **Subscribe** on Free plan
- Choose your predix account login from **Org** drop-down list
- Choose **dev** from **Space** drop-down list
- Select your UAA service from **User Account & Authentication** drop-down
- Enter **Service instance name**, e.g. "asset"
- Choose **Free Service plan**
- Click **Create Service**
![Predix asset create](http://i.imgur.com/LOSi0yz.png)
- There is 1 item you need to copy down. This will be used for further Predix account configuring.
  - **Asset Service instance name**
- Scroll to the **DATA MANAGEMENT** section and click **Time Series** service
- [Repeat the previous steps](#repeat-asset-steps) (related to **Asset** service)
- There is 1 item you need to copy down. This will be used for further Predix account
configuring.
  - **Time Series Service instance name**

#### Install Predix web application

The following steps are provided in detail for Mac OSX, you can use similar instructions from
the links below for the different operating systems.

- **Install [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads) client**:
  - if [Homebrew](https://brew.sh/) package manager isn't installed on your Mac, install it as described in the [**Install Homebrew** section](https://brew.sh/)
  - in a terminal window run the command

    `brew install cloudfoundry/tap/cf-cli`

  ![CF install](http://i.imgur.com/zYn2ynh.png)
- If your Internet connection requires a proxy server, configure your proxy settings as described in
[Predix Developing through a network proxy](https://www.predix.io/resources/tutorials/tutorial-details.html?tutorial_id=1565).
- **Install [CF Predix](https://github.com/PredixDev/cf-predix)**, a plugin for the Cloud Foundry CLI
  - In a terminal window run the command

    `cf install-plugin https://github.com/PredixDev/cf-predix/releases/download/1.0.0/predix_osx`

  ![CF Predix install](http://i.imgur.com/3aqwjYL.png)
- **Log into the Predix Cloud**:
  - in a terminal window run the command

    `cf predix`

  - Choose one of the regional Point Of Presence (PoP) locations that your account is set up for. This information can be found in your registration welcome Predix email
  - Enter the Email and Password of your Predix account
  ![CF Predix login](http://i.imgur.com/5HgcTSl.png)
- **Download** [Electric Imp's Predix web application](./PredixWebApp/electric_imp_smart_fridge) files
- Open [web application manifest.yml](./PredixWebApp/electric_imp_smart_fridge/manifest.yml) file in a text editor.
  - In services section modify with the values obtained during the Predix account configuration steps
    - **UAA Service instance name**
    - **Asset Service instance name**
    - **Time Series Service instance name**
  - In the env section modify with the values obtained during the Predix account configuration steps
    - **Client ID**
    - **Client Secret**
  - In **applications** section
    - Choose a name for your application and modify **name** value
  ![Predix WebApp manifest](http://i.imgur.com/ckBNkxe.png)
- **Launch Predix Web Application**:
  - In a terminal window change directory to electric_imp_smart_fridge of Electric Imp's Predix SmartRefrigerator sample
  - Run command

    `cf push -f manifest.yml`

  ![Predix WebApp installation](http://i.imgur.com/uxnnWwZ.png)
  - If the command fails with *Server error, status code: 400, error code: 210003, message: The host is taken: ...*
    - choose another name for your application
    - modify manifest.yml
    - Run `cf push -f manifest.yml` command again
  ![Predix WebApp install result](http://i.imgur.com/cweRjq5.png)
- When the application launch has completed successfully, run the command below to get your application's environment variables. The output will be used for further Predix account configuring and the demo agent code initialization.
  - Run command

    `cf env <your_web_application_name>`

  - There are 5 items you need to copy down from the command output

    1. Your **Asset URL**<a id=asset-url>, can be found in **System-Provided->VCAP_SERVICES->predix-asset->credentials->uri** value

    2. Your **Asset Zone ID**<a id=asset-zone-id>, can be found in **System-Provided->VCAP_SERVICES->predix-asset->credentials->zone->http-header-value**
    ![Predix Asset info](http://i.imgur.com/3voLJqs.png)

    3. Your **Time Series Zone ID**<a id=time-series-zone-id>, can be found in **System-Provided->VCAP_SERVICES->predix-timeseries->credentials->ingest->zone-http-header-value**
    ![Predix TimeSeries info](http://i.imgur.com/eM12iWk.png)

    4. Your **UAA URL**<a id=uaa-url>, can be found in **System-Provided->VCAP_SERVICES->predix-uaa->credentials->uri**
    ![Predix TimeSeries info](http://i.imgur.com/EZHWB8b.png)

    5. Your **Web Application URL**<a id=web-application-url>, can be found in **VCAP_APPLICATION->application_uris**
    ![Predix WebApp URL](http://i.imgur.com/Fj35LbL.png)

- Go back to your **UAA Service instance** page in your web browser and choose your client
  - In the **Authorized Services** section:
    - Click on the **Choose Service** box and select your **Asset Service instance name**, your asset should show up below the Choose Service box
    - Click **Choose Service** box again and select your **Time Series Service instance name**, it should show up below the Choose Service box
    - Click **Submit**
    ![Predix UAA client configure](http://i.imgur.com/9QdHglm.png)
  - Find your [Time Series Zone ID](#time-series-zone-id) from the previous step - item #3, you will need this for the next step
  - Next to **Client Info** heading click **Edit**
  ![Predix UAA client configure](http://i.imgur.com/KY4UQHT.png)
    - In the **Scopes** field
      - Fill in `timeseries.zones.<Time Series Zone ID>.ingest` and press "Enter"
      ![Predix UAA edit](http://i.imgur.com/i9omNUc.png)
      - Similarly fill in `timeseries.zones.<Time Series Zone ID>.query` and press "Enter"
    - In the **Authorities** field
      - Fill in `timeseries.zones.<Time Series Zone ID>.ingest` and press "Enter"
      - Fill in `timeseries.zones.<Time Series Zone ID>.query` and press "Enter"
    - Click **Save**
    ![Predix UAA edit](http://i.imgur.com/S8gzk7Z.png)

### Step 3 - Connect your Electric Imp to the Internet

#### Set Up Hardware

1. Plug the Imp001 into the Explorer Kit Board
2. Power up your Imp with the AA batteries.

![Explorer Kit](http://i.imgur.com/6JssX74.png)

When the imp is first powered on it will blink amber/red.

#### Electric Imp BlinkUp

Use the Electric Imp mobile app to BlinkUp your device

1. In the app log into your Electric Imp developer account
2. Enter your WIFI credentials
3. Follow the instructions in the app to BlinkUp your device

When BlinkUp is successful the imp will blink green and the app will show you the device's unique ID.

<img src="http://i.imgur.com/rljkSnI.png" width="250">

For more information on BlinkUp visit the Electric Imp [Dev Center](https://electricimp.com/docs/gettingstarted/blinkup/).

### Step 4 - Connect your Electric Imp to Predix IoT

- In your web browser log into the [Electric Imp IDE](https://ide.electricimp.com/login) using your Electric Imp developer account.
- Click the **+** button to create a new model
![Empty IDE](http://i.imgur.com/Ui7w8eG.png)
- In the pop-up enter the following information:

1. A name for your code model (ie Smart Refrigerator)
2. Select the checkbox next to your device ID, this assigns your device to this code model
3. Click **Create Model** button

- Copy and paste [Predix Smart Refrigerator agent code](./SmartRefrigerator_Predix.agent.nut) and [Predix Smart Refrigerator device code](./SmartRefrigerator_Predix.device.nut) into the agent and device coding windows.
![IDE code windows](http://i.imgur.com/yiCmQZu.png)

- Scroll to the bottom of the agent code to find *Predix account constants* variables.
  - Enter the following values from **Step 2** into the corresponding variables:
    - [**UAA URL**](#uaa-url)
    - [**Client ID**](#client-id)
    - [**Client secret**](#client-secret)
    - [**Asset URL**](#asset-url)
    - [**Asset Zone ID**](#asset-zone-id)
    - [**Time Series Zone ID**](#time-series-zone-id)
  - For the **TIME_SERIES_INGEST_URL** copy the [**WEB_APPLICATION_URL**](#web-application-url) value prefixed by "https://" and postfixed by "/ingest_data".

  It should look like

  `const TIME_SERIES_INGEST_URL = "https://electricimp-smart-fridge.run.aws-usw02-pr.ice.predix.io/ingest_data";`

- Click **Build and Run** to save and launch the code
![IDE with code](http://i.imgur.com/lnoCtKR.png)

Take note of your **device ID** specified in the bottom left corner. It can be useful on the next step.

### Step 5 - Refrigerator data visualization

- Open your [**Web Application URL**](#web-application-url) prefixed by "https://" in your web browser.
- Select your device ID from drop down list and click **Sensors Data**.
- On the device page you can see the current temerature and humidity values, door status and alerts over the past hour.
![Predix Web App](http://i.imgur.com/SU2du1n.png)

### Step 6 - Install the Imp in your Refrigerator

Open your refrigerator and place the Imp on a shelf in the door.

![Imp In Fridge](http://i.imgur.com/z5llZBg.png)

### Step 7 - Optional Improvements

Your refrigerator is now connected to the internet. As you begin to gather data for your refrigerator you should adjust the static variables in your device SmartFridgeApp class to further customize your integration.

* Adjust the temperature, humidity, and lighting thresholds to optimize for your frigde
* Adjust the reading and reporting times to optimize power usage
