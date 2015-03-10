# Project Rainbow
Elevation data displayed as a heatmap using the [Google Maps JavaScript API v3.18](https://developers.google.com/maps/documentation/javascript/reference)

## Running Locally
`php -S localhost:<PORT>`

## Building Locally
`npm install` (may require `sudo`)
`gulp`

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