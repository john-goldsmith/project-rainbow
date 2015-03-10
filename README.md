# Project Rainbow
Elevation data displayed as a heatmap using the [Google Maps JavaScript API v3.18](https://developers.google.com/maps/documentation/javascript/reference)

## Viewing Online
Visit [http://john-goldsmith.github.io/project-rainbow/](http://john-goldsmith.github.io/project-rainbow/)

## Running Locally
Because of how this project has been configured via the [Google Developer Console](https://console.developers.google.com/), it will only accept requests from `localhost` and `127.0.0.1`.  Thus, a local web server will need to be run.  For example, if PHP is installed, a web server can be started by running the following...

`php -S localhost:<PORT>`

...where `<PORT>` is a port of your choosing (`8888` for example).  Then, in your browser of choice, visit [http://localhost:PORT/dist/index.html](http://localhost:PORT/dist/index.html).

## Building Locally
1. Ensure that [Node](https://nodejs.org/) is installed.
1. Run `npm install` (may require `sudo`) in the project root directory which will install all required dependencies.
1. Run `gulp` which will create a `dist` folder with the compiled project assets.

## APIs Used
- [Map class](https://developers.google.com/maps/documentation/javascript/reference#Map)
- [MapOptions object](https://developers.google.com/maps/documentation/javascript/reference#MapOptions)
- [MapTypeId class](https://developers.google.com/maps/documentation/javascript/reference#MapTypeId)
- [LatLng class](https://developers.google.com/maps/documentation/javascript/reference#LatLng)
- [Event namespace](https://developers.google.com/maps/documentation/javascript/reference#event)
- [ElevationService class](https://developers.google.com/maps/documentation/javascript/reference#ElevationService)
- [ElevationStatus class](https://developers.google.com/maps/documentation/javascript/reference#ElevationStatus)
- [LocationElevationRequest object](https://developers.google.com/maps/documentation/javascript/reference#LocationElevationRequest)
- [ElevationResult object](https://developers.google.com/maps/documentation/javascript/reference#ElevationResult)
- [HeatmapLayer class](https://developers.google.com/maps/documentation/javascript/reference#HeatmapLayer)
- [HeatmapLayerOptions object](https://developers.google.com/maps/documentation/javascript/reference#HeatmapLayerOptions)
- [WeightedLocation object](https://developers.google.com/maps/documentation/javascript/reference#WeightedLocation)

## To Do
- Tests!
- Provide better user feedback when geolocation data or elevation data is being gathered
- Figure out a better weighted location equation
- Add option to display weather/temperature/wind/cloud data
- Remove dependency on jQuery

## Brainstorming Ideas
- ROYGBIV
  - Shapes: circle, triangle, square, pentagon, hexagon, star, diamond
  - Elements: fire, wind, light, earth, water, poison, dark?
  - Odd number: there can never be a loser
- Prisms: one player is the sun, another is a rain drop, objective is to create a rainbow
- Bejeweled clone
- [Blendoku](https://play.google.com/store/apps/details?id=com.lonelyfew.blendoku&hl=en) clone
- Minecraft
- Google Maps