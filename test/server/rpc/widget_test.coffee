assert = require 'assert'

describe "Widget", ->
  
  describe "#create", ->

    describe "if successful", ->

      it "should create a widget in the dashboard", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          ass.rpc 'widget.create', {name: "Sales Widget", dashboardId: dashboard._id}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].widget.name, "Sales Widget"
            Dashboard.findOne {_id: dashboard._id}, (err, dashboardReloaded) ->
              assert.equal dashboardReloaded.widgets[dashboardReloaded.widgets.length-1].name, "Sales Widget"
              done()

      it "should scope the widget's css", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          css = ".content { background: blue; }"
          ass.rpc 'widget.create', {name: "Sales Widget", dashboardId: dashboard._id, css: css}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].widget.scopedCSS, ".widget[data-id='" + res[0].widget._id + "'] .content { background: blue; }"
            done()

      it "should append the widget id and the api key to the JSON", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          json = JSON.stringify value: 76
          ass.rpc 'widget.create', {name: "Sales Widget", dashboardId: dashboard._id, json: json}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal JSON.parse(res[0].widget.json)._id, res[0].widget._id
            User.findOne {_id: dashboard.userId}, (err, user) ->
              assert.equal JSON.parse(res[0].widget.json).apiKey, user.apiKey
              done()

      it "should emit a widgetCreated event to the user's channel, with the dashboard id, and the widget"

    describe "if not successful", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc 'widget.create', {name: "Finance Widget", dashboardId: "231312312"}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "dashboard with id 231312312 not found"
          done()

  describe "#update", ->

    describe "if successful", ->

      it "should update the widget with the new attributes", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          widget = dashboard.widgets[0]
          newName = "Revenue Widget"
          ass.rpc "widget.update", {dashboardId: dashboard._id, _id: widget._id, name: newName}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].widget._id, widget._id.toString()
            assert.equal res[0].widget.name, newName
            assert.notEqual res[0].widget.createdAt, res[0].widget.updatedAt 
            # We're checking if the update is within a 1 second range
            assert (Date.now() - Date.parse(res[0].widget.updatedAt)) < 1000
            done()

      it "should append the widget id and the api key to the new JSON", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          widget = dashboard.widgets[0]
          json = JSON.stringify value: 79
          ass.rpc "widget.update", {dashboardId: dashboard._id, _id: widget._id, json: json}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal JSON.parse(res[0].widget.json)._id, res[0].widget._id
            User.findOne {_id: dashboard.userId}, (err, user) ->
              assert.equal JSON.parse(res[0].widget.json).apiKey, user.apiKey
              assert.equal JSON.parse(res[0].widget.json).value, 79
              done()

      it "should scope the widget's css", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          widget = dashboard.widgets[0]
          css = ".content { background: red; }"
          ass.rpc "widget.update", {dashboardId: dashboard._id, _id: widget._id, css: css}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].widget.scopedCSS, ".widget[data-id='" + res[0].widget._id + "'] .content { background: red; }"
            done()

      it "should emit the widgetUpdated event to the user's channel, with the dashboard id, and the widget"

    describe "if not successful because dashboard id is wrong", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "widget.update", {dashboardId: "waa", _id: "woo", name: "Wey"}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "No dashboard found with id waa"
          done()

    describe "if not successful because widget id is wrong", ->

      it "should return a failure status and explain what went wrong", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          ass.rpc "widget.update", {dashboardId: dashboard._id, _id: "woo", name: "Wey"}, (res) ->
            assert.equal res[0].status, "failure"
            assert.equal res[0].reason, "No widget found with id woo"
            done()

  describe "#delete", ->

    describe "if successful", ->

      it "should remove the widget from the dashboard, and return a success status along with the widget's id", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          widget = dashboard.widgets[dashboard.widgets.length-1]
          ass.rpc "widget.delete", {dashboardId: dashboard._id, _id: widget._id}, (res) ->
            assert.equal res[0].status, "success"
            assert.equal res[0].widgetId, widget._id.toString()
            Dashboard.findOne {_id: dashboard._id}, (err, dashboardReloaded) ->
              assert.equal dashboardReloaded.widgets.length + 1, dashboard.widgets.length 
              done()

      it "should emit the widgetDeleted event to the user's channel, with the dashboard id, and the widget id"

    describe "if not successful because dashboard id is wrong", ->

      it "should return a failure status and explain what went wrong", (done) ->
        ass.rpc "widget.delete", {dashboardId: "waa", _id: "woo"}, (res) ->
          assert.equal res[0].status, "failure"
          assert.equal res[0].reason, "No dashboard found with id waa"
          done()

    describe "if not successful because widget id is wrong", ->

      it "should return a failure status and explain what went wrong", (done) ->
        Dashboard.findOne {}, (err, dashboard) ->
          ass.rpc "widget.delete", {dashboardId: dashboard._id, _id: "woo"}, (res) ->
            assert.equal res[0].status, "failure"
            assert.equal res[0].reason, "No widget found with id woo"
            done()