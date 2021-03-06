angular.module "mb.resources", ["ngResource", "mb.filters"], ($provide) ->

  $provide.factory "Database", [
    "$resource", ($resource) ->

      paramDefaults = dbName: "@name"
      $resource "/api/databases/:dbName/:action", paramDefaults,
        query: { method: "GET", isArray: true },
        stats: { method: "GET", params: { action: "stats" } }
  ]

  $provide.factory "Collection", [
    "$resource", "$filter", ($resource, $filter) ->

      paramDefaults = dbName: "@dbName", collectionName: "@name"
      $resource "/api#{$filter("collectionsPath")()}/:collectionName/:action",
        paramDefaults,
          query: { method: "GET", isArray: true },
          stats: { method: "GET", params: { action: "stats" } }
  ]

  $provide.factory "Document", [
    "$resource", "$filter", ($resource, $filter) ->

      paramDefaults = dbName: "@dbName", collectionName: "@collectionName", id: "@id"
      $resource "/api#{$filter("documentsPath")()}/:id", paramDefaults,
        query: method: "GET", isArray: false
  ]
