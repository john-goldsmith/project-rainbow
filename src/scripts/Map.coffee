class Map

  POINT_DENSITY = 900 # The number of location points
  REQUEST_CHUNKS = 6 # The number of requests made to retrieve all data

  world =
    map: null
    latLngPoints: []
    elevations: []
    weightedLocations: []

  constructor: ->
    # 37.774546, -122.433523 # San Franciso
    center = new google.maps.LatLng 36.556386, -117.015124 # Death Valley
    mapOptions =
      center: center
      zoom: 7
      mapTypeId: google.maps.MapTypeId.ROADMAP
    world.map = new google.maps.Map document.getElementById("map-canvas"), mapOptions
    google.maps.event.addListener world.map, "idle", onMapReady
    # google.maps.event.addDomListener(window, "load", initialize)

  # getLocation = ->
  #   if navigator.geolocation then navigator.geolocation.getCurrentPosition(showPosition) else $("#map-canvas").html("Geolocation is not supported by this browser.")

  # showPosition = (position) ->
    # $("#map-canvas").html("Latitude: #{position.coords.latitude}<br>Longitude: #{position.coords.longitude}")

  # getLocation();

  onMapReady = ->
    top = world.map.getBounds().getNorthEast().lat()
    right = world.map.getBounds().getNorthEast().lng()
    bottom = world.map.getBounds().getSouthWest().lat()
    left = world.map.getBounds().getSouthWest().lng()

    latSpread = Math.abs top - bottom
    lngSpread = Math.abs left - right

    latFactor = latSpread / Math.sqrt POINT_DENSITY
    lngFactor = lngSpread / Math.sqrt POINT_DENSITY

    points = Math.ceil Math.sqrt POINT_DENSITY

    world.latLngPoints = [] # Clear previous points
    for lat in [0..points]
      for lng in [0..points]
        world.latLngPoints.push new google.maps.LatLng top - (lat * latFactor), left + (lng * lngFactor)

    recursivleyGetElevationData()

  # getElevations = ->
  #   elevationService = new google.maps.ElevationService()
  #   locationElevationRequest =
  #     locations: world.latLngPoints
  #   elevationService.getElevationForLocations locationElevationRequest, (result, status) ->
  #     # TODO: First check for status; see https://developers.google.com/maps/documentation/javascript/reference#ElevationStatus
  #     if status is google.maps.ElevationStatus.OK
  #       world.elevations = result
  #       getWeightedLocations()
  #       renderHeatmap()
  #     else
  #       console.log status

  getWeightedLocations = ->
    world.weightedLocations = []
    elevations = []
    for item in world.elevations
      elevations.push item.elevation
      if item.elevation > 0 # Ignore anything below sea level
        # weight = () / (Math.max.apply(null, elevations) - Math.min.apply(null, elevations))
        world.weightedLocations.push
          location: item.location
          weight: item.elevation
        # weight: if item.elevation < 0 then 0 else item.elevation
    console.log world.weightedLocations
    # ((elevInRange - this.minElevation) / (this.maxElevation - this.minElevation))

  recursivleyGetElevationData = (step = 0) ->
    chunks = Math.ceil world.latLngPoints.length / REQUEST_CHUNKS # 961 / 6 = 161 (160.2)
    begin = step * (chunks + 1) # 0, 162, 324, ...
    end = (step + 1) * (chunks + 1) # 162, 324, ...
    console.log "#{begin} - #{end}"

    if begin > POINT_DENSITY
      world.elevations = $.map world.elevations, (i) ->
        return i
      getWeightedLocations()
      renderHeatmap()
      return

    points = world.latLngPoints.slice begin, end

    elevationService = new google.maps.ElevationService()
    locationElevationRequestChunk =
      locations: points
    elevationService.getElevationForLocations locationElevationRequestChunk, (result, status) ->
      if status is google.maps.ElevationStatus.OK
        console.log "OK"
        world.elevations.push result
        recursivleyGetElevationData step + 1
      else
        console.log "NOT OK: #{status}"

  renderHeatmap = ->
    if world.heatmapLayer then updateHeatmapLayerData() else createHeatmapLayer()

  createHeatmapLayer = ->
    heatmapLayerOptions =
      data: world.weightedLocations
      gradient: [
        "rgba(255, 255, 255, 0)" # White
        "rgba(249, 107, 107, 1)" # R
        "rgba(249, 187, 107, 1)" # O
        "rgba(249, 249, 107, 1)" # Y
        "rgba(107, 249, 107, 1)" # G
        "rgba(107, 107, 249, 1)" # B
        "rgba(171, 107, 249, 1)" # I
        "rgba(249, 107, 249, 1)" # V
        # "rgba(0, 0, 0, 1)" # Black
        # "rgba(255, 255, 255, 1)" # White
      ]
      map: world.map
      # maxIntensity: 1
      # opacity: 1
      radius: 80
    # mvcArray = new google.maps.MVCArray world.elevations
    world.heatmapLayer = new google.maps.visualization.HeatmapLayer heatmapLayerOptions

  updateHeatmapLayerData = ->
    world.heatmapLayer.setData world.weightedLocations

$(document).ready =>
  @app ?= {}
  @app.map = new Map