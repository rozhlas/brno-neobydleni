titles =
  ratio          : "Neobsazených bytů"
  bezKoupelny    : "Bez koupelny"
  bezTepleVody   : "Bez teplé vody"
  snizenaKvalita : "Snížené kvality"
  bezZachodu     : "Bez záchodu"
  bezVodovodu    : "Bez vodovodu"
  sKamny         : "S kamny"
  najemni        : "Nájemní"
class ig.Map
  (@container, @geojson, displayedProperty, colorScale, @onMouseover) ->
    @init!
    @addTiles!
    @generateGeojsonLayer displayedProperty, colorScale .addTo @map

  generateGeojsons: (properties) ->
    layersAssoc = {}
    for property in properties
      layer = @generateGeojsonLayer property
      layersAssoc[property] = layer
    layersAssoc.ratio.addTo @map
    @layerControl = L.control.layers layersAssoc, {}
    @layerControl.addTo @map

  generateGeojsonLayer: (property, colorScale) ->
    features = @geojson.features.filter -> !isNaN it.properties[property]
    filteredGeojson = {features}
    color = d3.scale.quantile!
      ..domain filteredGeojson.features.map (.properties[property])
      ..range colorScale
    @geojsonLayer := L.geoJson do
      * filteredGeojson
      * style: (feature) ->
          weight: 1
          color: color feature.properties[property]
          fillOpacity: 0.7
        onEachFeature: (feature, layer) ~>
          {properties} = feature
          layer.on \mouseover ~> @onMouseover feature
    @geojsonLayer

  init: ->
    @element = @container.append \div
      ..attr \class \map

    @map = L.map do
      * @element.node!
      * minZoom: 10,
        maxZoom: 16,
        zoom: 13,
        center: [49.205 16.61]
        maxBounds: [[49.124,16.475], [49.289,16.716]]

  addTiles: ->
    baseLayer = L.tileLayer do
      * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
      * zIndex: 1
        opacity: 1
        attribution: 'mapová data &copy; přispěvatelé <a target="_blank" href="http://osm.org">OpenStreetMap</a>, obrazový podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

    labelLayer = L.tileLayer do
      * "https://samizdat.cz/tiles/ton_l2/{z}/{x}/{y}.png"
      * zIndex: 3
        opacity: 0.75

    @map.addLayer baseLayer
    @map.addLayer labelLayer


