class Map

  # Workflow:
  #   Create a map instance
  #   Given the NE and SW coordinates, get top, right, bottom, and left bounds
  #   Calculate the number of data points in each direction
  #   Create a collection of location points
  #   Get elevation data for each location point (in chunks to circumvent Google rate limits)
  #   Create weighted location points using elevation spread
  #   Render heatmap using weighted location points
  #   ???
  #   Profit

  # The following determines the number of location points that will be
  # rendered in the viewport. A higher number means more a more accurate
  # depiction of elevation, but is more API and resource intensive.
  # Conversely, a smaller number of points will be faster, but provide
  # less accurate data.
  POINT_DENSITY = 1024

  # Because Google limits the rate of API calls, the following determines
  # the number of requests made to the Google Elevation Service in order
  # to retrieve elevation data for each location point.
  REQUEST_CHUNKS = 6

  # The following sets a default location in the event that there is
  # an error retrieiving the user's geolocation, or the browser being
  # used doesn't have the geolocation feature.
  DEFAULT_LOCATION = new google.maps.LatLng 33.582807, -117.727651 # Gaikai, Aliso Viejo

  # Set the default zoom level
  DEFAULT_ZOOM = 7

  # Colors are ascending in elevation, the first being nearer to sea
  # level and the last being farther away.
  GRADIENT = [
    "rgba(255, 255, 255, 0)" # Transparent base
    "rgba(249, 107, 107, 1)" # R
    "rgba(249, 187, 107, 1)" # O
    "rgba(249, 249, 107, 1)" # Y
    "rgba(107, 249, 107, 1)" # G
    "rgba(107, 107, 249, 1)" # B
    "rgba(171, 107, 249, 1)" # I
    "rgba(249, 107, 249, 1)" # V
  ]

  # Private members
  map = null
  heatmapLayer = null
  latLngPoints = []
  allElevations = []
  weightedLocations = []
  chunkSize = 0

  # Public methods
  constructor: ->
    getGeoLocation().then(
      (geoLocation) ->
        createMap geoLocation
      , (fallbackLocation) ->
        createMap fallbackLocation
    )

  # Private methods
  createMap = (center) ->
    mapOptions =
      center: center
      zoom: DEFAULT_ZOOM || 7
      mapTypeId: google.maps.MapTypeId.ROADMAP
    map = new google.maps.Map document.getElementById("map-canvas"), mapOptions

    # This event is fired when the map becomes idle after panning or
    # zooming.
    google.maps.event.addListener map, "idle", onMapReady

  getGeoLocation = ->
    deferred = Q.defer()
    if navigator.geolocation
      console.log "Getting geolocation data..."
      navigator.geolocation.getCurrentPosition(
        (position) ->
          deferred.resolve new google.maps.LatLng position.coords.latitude, position.coords.longitude
        , (error) ->
          console.log "Error (#{error.code}): #{error.message}"
          deferred.reject DEFAULT_LOCATION
        ,
          enableHighAccuracy: true # Potential battery impact; consider mobile devices
          timeout: 5000
          maximumAge: 0 # Don't used cached location data
      )
    else
      console.log "navigator.geolocation not available; using default location"
      deferred.reject DEFAULT_LOCATION

    deferred.promise

  onMapReady = ->
    setLatLngPoints()
    setRequestChunks()
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

  setRequestChunks = ->
    chunkSize = Math.ceil latLngPoints.length / REQUEST_CHUNKS

  getElevationData = (step = 0) ->
    begin = step * (chunkSize + 1)
    end = (step + 1) * (chunkSize + 1)

    # Because this method is called recursively, a condition is needed
    # in order to know when to stop execution.
    # TODO: Maybe use a promise here instead? Not sure how that works
    # inside recursion.
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
          weight: item.elevation # TODO: Figure out better weighting equation

  renderHeatmap = ->
    if heatmapLayer then heatmapLayer.setMap null # Remove the existing heatmap
    heatmapLayerOptions =
      data: weightedLocations
      gradient: GRADIENT
      map: map
      radius: getRadius()
    heatmapLayer = new google.maps.visualization.HeatmapLayer heatmapLayerOptions

  getRadius = ->
    # There's no ryhme or reason to the number 6 other than that it
    # seems to produce good visuals.
    map.getZoom() * 6

$(document).ready =>
  @app ?= {}
  @app.map = new Map