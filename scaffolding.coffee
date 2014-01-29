Router.configure
  layoutTemplate: "layout"

Router.map ->
  @route "/",
    path: "/"
    #layoutTemplate: "main"
    #layoutTemplate: "layout"
    yieldTemplates:
      leftSidebar:
        to: "leftSidebar"
    #  rightSidebar:
    #    to: "rightSidebar"
    #template: "main"
    before: ->
      console.log "GRRR"

    #data: ->
    #  console.log "ROUTER INITIALIZED!"
    #action: ->
    #  console.log "Action :)"
  #@route "/contentProfile",
  #  path: "/hello"
  #  before: ->
  #    console.log "ANOTHER PAGE"

if Meteor.isClient
  @toggleClickMenu = (e,t) ->
    console.log "toggleClickMenu called!"
    console.log "e: ",e
    console.log "t: ",t
    console.log "clickMenuTimeout: ",clickMenuTimeout

  UI.body.events
    "click [data-action='toggleSidebar']": (e,t) ->
      console.log "Toggling Sidebar"
      currentTarget = $(e.currentTarget)
      console.log currentTarget
      sidebar = currentTarget.data("sidebar")


if Meteor.isServer
  console.log "Server"
