describe "services", ->
  beforeEach module("mb.services")

  describe "tableFilter", ->
    scope = null
    tableFilter = null

    beforeEach inject ($injector) ->
      factory = $injector.get('tableFilterFactory')

      scope =
        dummyCollection: [
            name: "first_item"
          ,
            name: "second_item"
          ,
            name: "third"
        ]

      tableFilter = factory(scope, "dummyCollection")

    describe "#filter", ->
      it "filters the given collection", ->
        expect(tableFilter).toBeDefined()

        tableFilter.filter("first")
        expect(scope.dummyCollection.length).toEqual(1)
        expect(tableFilter.collectionCopy.length).toEqual(3)
        expect(scope.dummyCollection).toContain(name: "first_item")

        tableFilter.filter("item")
        expect(scope.dummyCollection.length).toEqual(2)
        expect(tableFilter.collectionCopy.length).toEqual(3)
        expect(scope.dummyCollection).toContain(name: "first_item")
        expect(scope.dummyCollection).toContain(name: "second_item")

        tableFilter.filter("fourth")
        expect(scope.dummyCollection.length).toEqual(0)
        expect(tableFilter.collectionCopy.length).toEqual(3)

    describe "#matchesCount", ->
      it "returns a number of matches elements", ->
        tableFilter.filter("")
        expect(tableFilter.matchesCount()).toEqual(3)

        tableFilter.filter("item")
        expect(tableFilter.matchesCount()).toEqual(2)

        tableFilter.filter("third")
        expect(tableFilter.matchesCount()).toEqual(1)

        tableFilter.filter("fourth")
        expect(tableFilter.matchesCount()).toEqual(0)

    describe "#noMatches", ->
      it "returs true if filtered collection is empty", ->
        tableFilter.filter("fourth")
        expect(tableFilter.noMatches()).toBeTruthy()

      it "return false if filtered collection is not empty", ->
        tableFilter.filter("item")
        expect(tableFilter.noMatches()).toBeFalsy()

  # TODO add spec for defaultDialogsHandler
  describe "bootboxDialogsHandler", ->
    beforeEach inject ($window) ->
      $window.bootbox = 'dummy bootbox'

    it "by default is set to bootbox", inject (bootboxDialogsHandler) ->
      expect(bootboxDialogsHandler).toEqual('dummy bootbox')

  describe "confirmationDialog", ->
    beforeEach module("mocks")

    it "is defined", inject (confirmationDialog) ->
      expect(confirmationDialog).toBeDefined()

    it "calls the handler", inject (confirmationDialog, bootboxDialogsHandler) ->
      # Given
      spyOn(bootboxDialogsHandler, "confirm")

      # When
      confirmationDialog(message: "This is a test message")

      # Then
      expect(bootboxDialogsHandler.confirm).toHaveBeenCalledWith \
          "This is a test message",
          jasmine.any(Function)

    describe "when the dialog was confirmed", ->
      it "calls the given #onOk callback", inject (confirmationDialog, bootboxDialogsHandler) ->
        # Given
        onOk = jasmine.createSpy("#onOk callback")
        confirmationDialog(onOk: onOk)

        # When
        bootboxDialogsHandler.confirmed()

        # Then
        expect(onOk).toHaveBeenCalled()

    describe "when the dialog was disposed", ->
      it "calls the given #onOk callback", inject (confirmationDialog, bootboxDialogsHandler) ->
        # Given
        onCancel= jasmine.createSpy("#onCancel callback")
        confirmationDialog(onCancel: onCancel)

        # When
        bootboxDialogsHandler.disposed()

        # Then
        expect(onCancel).toHaveBeenCalled()

  describe "alerts", ->
    it "is defined", inject (alerts) ->
      expect(alerts).toBeDefined()

    describe "#nextId", ->
      it "return the next id for the new flash message", inject (alerts) ->
        expect(alerts.nextId()).toEqual(1)
        _(4).times -> alerts.nextId()
        expect(alerts.nextId()).toEqual(6)

    describe "#push", ->
      beforeEach inject (alerts) ->
        spyOn(alerts, "delayedDispose")

      it "returns an id for the new flash message", inject (alerts) ->
        expect(alerts.push("info", "Test..")).toEqual(1)
        expect(alerts.delayedDispose).toHaveBeenCalledWith(1)

        expect(alerts.push("error", "Test error..")).toEqual(2)
        expect(alerts.delayedDispose).toHaveBeenCalledWith(2)

      describe "#info", ->
        it "pushesh the given message", inject (alerts) ->
          # Given
          testMessage = "This is a test message!"
          otherTestMessage = "This is a second test message!"

          # When
          alerts.info(testMessage)
          expect(alerts.delayedDispose).toHaveBeenCalledWith(1)

          alerts.info(otherTestMessage)
          expect(alerts.delayedDispose).toHaveBeenCalledWith(2)

          # Then
          expect(alerts.messages).toContain(id: 1, type: "info", text: testMessage)
          expect(alerts.messages).toContain(id: 2, type: "info", text: otherTestMessage)

      describe "#error", ->
        it "pushesh the given message", inject (alerts) ->
          # Given
          testMessage = "This is a test message!"

          # When
          alerts.error(testMessage)
          expect(alerts.delayedDispose).toHaveBeenCalledWith(1)

          # Then
          expect(alerts.messages).toContain(id: 1, type: "error", text: testMessage)

    describe "#dispose", ->
      it "removes a message with the given id", inject (alerts) ->
        # Given
        alerts.info("First message")
        alerts.info("Second message")
        alerts.info("Third message")
        alerts.error("Error message")

        # When
        alerts.dispose(2)

        # Then
        expect(alerts.messages).toContain(id: 1, type: "info", text: "First message")
        expect(alerts.messages).not.toContain(id: 2, type: "info", text: "Second message")
        expect(alerts.messages).toContain(id: 3, type: "info", text: "Third message")
        expect(alerts.messages).toContain(id: 4, type: "error", text: "Error message")

    describe "#delayedDispose", ->
      it "remove a message after the given time", inject (alerts, $timeout) ->
        # Given
        alerts.info("First message")

        # When
        alerts.delayedDispose(1)
        $timeout.flush()

        # Then
        expect(alerts.messages).toEqual([])
