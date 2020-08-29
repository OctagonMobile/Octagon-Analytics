# Octagon Analytics

This is the native iOS Application for [Kibana](https://www.elastic.co/products/kibana).<br/>

Click [here](https://apps.apple.com/us/app/octagon-analytics/id1492910295) to download Octagon Analytics app.

Supported Devices: iPhone & iPad.

## Table of Contents
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Configure App Settings](#configure-app-settings)
* [Usage](#usage)
* [Supported Features](#supported-features)
* [Contributing](#contributing)
* [License](#license)

## Prerequisites<a id="prerequisites"></a>
Make sure that you have the following applications:
1.  Kibana server(v-6.5.4) with Octagon-Analytics-Plugin :
	* [Build](https://octagonmobile.github.io/Octagon-Analytics-Plugin-Download/Octagon-Analytics-6.5.4.zip).
	* [Source Code](https://github.com/OctagonMobile/Octagon-Analytics-Plugin.git).
2.  Xcode (version 11.0 or above).
3.  [Cocoapods](https://cocoapods.org) installed on Mac.

## Installation<a id="installation"></a>

* Checkout the sourcecode from [here](https://github.com/OctagonMobile/Octagon-Analytics.git).
* Open 'Terminal' and change directory to project directory.<br/>
```bash
cd ~/Your_Project_Folder
```

* Run the command.<br/>
`pod install`

* Open "*OctagonAnalytics.xcworkspace*" file.

## Configure App Settings<a id="configure-app-settings"></a>

- Open ***Configuration.swift*** file and set the following:

| Configuration  			| Value 		|	Class/Function |
| ------------- 			| ------------- | ------------- |
| SCHEME  					| http/https  ||
| BASE_URL  				| Kibana URL (xx.xx.xx.xx)  ||
| PORT  					| Port  (xxxx)||
| MAP_URL  					| Map url<br/>(Required only if you are using custom map layers) |enum **Environment**|
| IMAGE_HASH_URL  			| Image hash server url<br/>(Required only if you are using custom image hashing service)  |enum **Environment**|
| KEYCLOAK_CLIENT_ID  		| Keycloak client ID<br/>(Required only if you integrate keycloak) |enum **Environment**|
| KEYCLOAK_CLIENT_SECRET  	| Keycloak secret ID<br/>(Required only if you integrate keycloak)  |enum **Environment**|
| KEYCLOAK_HOST  			| Keycloak host<br/>(Required only if you integrate keycloak)  |enum **Environment**|
| KEYCLOAK_REALM  			| Keycloak realm name<br/>(Required only if you integrate keycloak)  |enum **Environment**|

- Open ***Info.plist*** and Replace "*com.MyCompany.octagonAnalytics*" under ++URL Schemes++ with your app bundle identifier. (Required for Keycloak)
- Open ***exportOptions.plist*** and Replace "*com.MyCompany.octagonAnalytics*" under ++provisioningProfiles++ with your app bundle identifier. (Auto Build generation - CICD)
- Open ***Root.plist*** under *"Settings.bundle"* and set default values for the following:
	1. Protocol: Http/Https
	2. Base Url: XX.XX.XX.XX
	3. Port: XXXX


## Usage<a id="usage"></a>

Generate the build and install it on the device or simulator.

Open the Settings App and configure Octagon Analytics.
*  Setup the following:
    *  URL
    *  Port
    *  Protocol (HTTP/HTTPS)
*  Set the supported authentication type. (If Kibana server doesn't need authentication then select "*None*" )

## Supported Features<a id="supported-features"></a>

*  Dashboard viewer.
*  Date range selection for dashboard.
*  Apply/Inverse dashboard filter.
*  Canvas viewer (X-Pack).
*  Authentication (Basic/Keycloak).
*  Touch ID/Face ID login.
*  App Theme (Light/Dark).
*  Localization(English/Arabic)
*  Supported visualizations are mentioned in [wiki](https://github.com/OctagonMobile/Octagon-Analytics/wikis/home#supported-visualizations) page.
*   Video Generation - BarChart Race & Vector Map.

## Contributing<a id="contributing"></a>
We welcome pull requests from the community!

## License<a id="license"></a>
[MIT](https://github.com/OctagonMobile/Octagon-Analytics/blob/master/LICENSE)


* Kibana is a trademark of Elasticsearch BV, registered in the US and in other countries.
