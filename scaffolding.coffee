Router.configure
  layoutTemplate: "layout"

Router.map ->
  @route "browse",
    path: "/"
    yieldTemplates:
      leftSidebar:
        to: "leftSidebar"
      rightSidebar:
        to: "rightSidebar"
    before: ->
      console.log "GRRR"
    #data: ->
    #  console.log "ROUTER INITIALIZED!"
    #action: ->
    #  console.log "Action :)"
  @route "about",
    path: "/about"
    yieldTemplates:
      leftSidebar:
        to: "leftSidebar"
      rightSidebar:
        to: "rightSidebar"
    before: ->
      console.log "About Page"
  @route "community",
    path: "/community"
    yieldTemplates:
      leftSidebar:
        to: "leftSidebar"
      rightSidebar:
        to: "rightSidebar"
    before: ->
      console.log "Community Page"

if Meteor.isClient
  @toggleClickMenu = (e,t) ->
    console.log "toggleClickMenu called!"
    console.log "e: ",e
    console.log "t: ",t
    console.log "clickMenuTimeout: ",clickMenuTimeout

  Template.layout.events
    "click [data-action='toggleSidebar']": (e,t) ->
      console.log "Toggling Sidebar"
      currentTarget = $(e.currentTarget)
      console.log currentTarget
      sidebar = currentTarget.data("sidebar")
    "click #login":(e,t)->
      console.log "Login clicked"
      Meteor.loginWithFacebook
        requestPermissions: ["publish_actions"]
      , (err) ->
        if err
          #error handling
          console.log err
        else
          #show an alert
          console.log "logged in"
    "click #signout":(e,t)->
      console.log "Signing out"
      Meteor.logout()
    "click .play":(e,t)->
      console.log "Playing video"
      $(".video")[0].play()
      #height = $(".video").height()
      #$(".play").hide()
      #$(".about").css("margin-top",height)
    "mousedown":(e,t)->
      console.log "FUCKING MOUSEDOWN"
      clickMenu = $(".clickMenu")
      clickMenuTopMargin = 20
      clickMenuLeftMargin = 20

      console.log "starting check!"
      console.log "e: ",e
      x = e.pageX
      y = e.pageY
      console.log "x: ",x
      console.log "y: ",y

      console.log "clickMenuTopMargin: ",clickMenuTopMargin
      console.log "clickMenuLeftMargin: ",clickMenuLeftMargin

      $(".clickMenu").css
        top: y - clickMenuTopMargin
        left: x - clickMenuLeftMargin

      #Global probably isn't best, but it works for now.
      window.clickMenuTimeout = Meteor.setTimeout(()->
        console.log "CLICKMENU TRIGGERED!"
        $(".clickMenu").addClass("activated")
      ,200)

      #console.log "clickMenuTimeout: ",clickMenuTimeout
    "mouseup":(e,t)->
      #console.log "mouseup"
      #Meteor.setTimeout(()->
      #console.log "clickMenuTimeout: ",clickMenuTimeout
      #Meteor.clearTimeout(clickMenuTimeout)
      $(".clickMenu").removeClass("activated")
      #,100)
      #log "clickMenuTimeout ",clickMenuTimeout
      Meteor.clearTimeout(clickMenuTimeout)
    "mouseover .node":(e,t)->
      #console.log "MOUSEOVER NODE!"
      currentTarget = $(e.currentTarget)
      unless currentTarget.hasClass("origin")
        $(e.currentTarget).addClass("hovered")
    "mouseout .node":(e,t)->
      #console.log "MOUSEOUT NODE!"
      currentTarget = $(e.currentTarget)
      unless currentTarget.hasClass("origin")
        $(currentTarget).removeClass("hovered")
    "mouseup .node":(e,t)->
      console.log "MOUSEUP ON A NODE!"
      currentTarget = $(e.currentTarget)
      action = currentTarget.data("action")
      console.log "action: ",action
      #Trigger different actions based on user input
      if action is "play"
        $(".video")[0].play()

if Meteor.isServer
  console.log "Server"
