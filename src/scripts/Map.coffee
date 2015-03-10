class Map

  # Workflow:
  #   Get bounds
  #   Calculate number of points in each direction
  #   Create collection of location points
  #   Get elevation data for each location point in chunks
  #   Create weighted location points using elevation spread
  #   Render heatmap using weighted location points

  POINT_DENSITY = 1024 # The number of location points
  REQUEST_CHUNKS = 6 # The number of requests made to retrieve all data

  map = null
  latLngPoints = []
  allElevations = []
  weightedLocations = []
  heatmapLayer = null

  constructor: ->
    getGeoLocation().then(
      (center) ->
        mapOptions =
          center: center
          zoom: 7
          mapTypeId: google.maps.MapTypeId.ROADMAP
        map = new google.maps.Map document.getElementById("map-canvas"), mapOptions
        google.maps.event.addListener map, "idle", onMapReady
    )

  getGeoLocation = ->
    deferred = Q.defer()
    if navigator.geolocation
      console.log "Getting geolocation data..."
      navigator.geolocation.getCurrentPosition(
        (position) ->
          deferred.resolve new google.maps.LatLng position.coords.latitude, position.coords.longitude
        , (error) ->
          console.log "Error (#{error.code}): #{error.message}"
          deferred.resolve new google.maps.LatLng 33.582807, -117.727651 # Gaikai, Aliso Viejo
        ,
          enableHighAccuracy: true
          timeout: 5000
          maximumAge: 0 # Don't used any cached data
      )
    else
      console.log "navigator.geolocation not available; using default location"
      deferred.resolve new google.maps.LatLng 33.582807, -117.727651 # Gaikai, Aliso Viejo

    deferred.promise

  onMapReady = ->
    setLatLngPoints()
    getElevationData()

  setLatLngPoints = ->
    top = map.getBounds().getNorthEast().lat()
    right = map.getBounds().getNorthEast().lng()
    bottom = map.getBounds().getSouthWest().lat()
    left = map.getBounds().getSouthWest().lng()

    latSpread = Math.abs top - bottom
    lngSpread = Math.abs left - right

    latFactor = latSpread / Math.sqrt POINT_DENSITY
    lngFactor = lngSpread / Math.sqrt POINT_DENSITY

    maxPoints = Math.ceil Math.sqrt POINT_DENSITY

    latLngPoints = [] # Clear previous points
    for lat in [0..maxPoints]
      for lng in [0..maxPoints]
        latLngPoints.push new google.maps.LatLng top - (lat * latFactor), left + (lng * lngFactor)

  getElevationData = (step = 0) ->
    chunkSize = Math.ceil latLngPoints.length / REQUEST_CHUNKS

    begin = step * (chunkSize + 1)
    end = (step + 1) * (chunkSize + 1)

    if begin > POINT_DENSITY
      flattenElevationData()
      setWeightedLocations()
      renderHeatmap()
      return

    elevationService = new google.maps.ElevationService()
    locationElevationRequestChunk =
      locations: latLngPoints.slice begin, end
    elevationService.getElevationForLocations locationElevationRequestChunk, (result, status) ->
      if status is google.maps.ElevationStatus.OK
        allElevations.push result
        getElevationData step + 1 # Recursion, yo
      else
        console.log "Error: #{status}"

  flattenElevationData = ->
    allElevations = $.map allElevations, (i) ->
      return i

  setWeightedLocations = ->
    weightedLocations = [] # Clear any previous data
    for item in allElevations
      if item.elevation > 0 # Ignore anything below sea level
        weightedLocations.push
          location: item.location
          weight: item.elevation # TODO: Figure out better weighting

  renderHeatmap = ->
    if heatmapLayer then updateHeatmapLayerData() else createHeatmapLayer()

  updateHeatmapLayerData = ->
    heatmapLayer.setData weightedLocations

  createHeatmapLayer = ->
    heatmapLayerOptions =
      data: weightedLocations
      gradient: [
        # Colors are ascending in elevation, red being nearer to sea
        # level and violet being farther away
        "rgba(255, 255, 255, 0)" # Transparent base
        "rgba(249, 107, 107, 1)" # R
        "rgba(249, 187, 107, 1)" # O
        "rgba(249, 249, 107, 1)" # Y
        "rgba(107, 249, 107, 1)" # G
        "rgba(107, 107, 249, 1)" # B
        "rgba(171, 107, 249, 1)" # I
        "rgba(249, 107, 249, 1)" # V
      ]
      map: map
      radius: 50 # TODO: Make this a function of zoom level
    heatmapLayer = new google.maps.visualization.HeatmapLayer heatmapLayerOptions

$(document).ready =>
  @app ?= {}
  @app.map = new Map