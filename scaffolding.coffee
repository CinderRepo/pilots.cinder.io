#Handlebars Helpers
Handlebars.registerHelper "focused", (context,value) ->
  if Session.equals("focused",this._id) and Session.equals("clickMenuActive",true)
    "focused"
  else if Session.equals("clickMenuActive",true)
    "blurred"
  else
    false
Handlebars.registerHelper "menuIs", (context,value) ->
  Session.equals "menu",context

#Data Collections
@Projects = new Meteor.Collection "projects"

Router.configure
  layoutTemplate: "layout"

Router.map ->
  @route "browse",
    path: "/"
    #yieldTemplates:
    #  leftSidebar:
    #    to: "leftSidebar"
    #  rightSidebar:
    #    to: "rightSidebar"
    before: ->
      console.log "GRRR"
    data: ->
      console.log "Data!"
      projects: Projects.find()
    #data: ->
    #  console.log "ROUTER INITIALIZED!"
    #action: ->
    #  console.log "Action :)"
  @route "about",
    path: "/about"
    #yieldTemplates:
    #  leftSidebar:
    #    to: "leftSidebar"
    #  rightSidebar:
    #    to: "rightSidebar"
    before: ->
      console.log "About Page"
  @route "community",
    path: "/community"
    #yieldTemplates:
    #  leftSidebar:
    #    to: "leftSidebar"
    #  rightSidebar:
    #    to: "rightSidebar"
    before: ->
      console.log "Community Page"

if Meteor.isClient
  #Allow for fastclick on mobile devices
  window.addEventListener "load", (->
    FastClick.attach document.body
    return
  ), false

  #Router Subscriptions
  @Subscriptions =
    projects: Meteor.subscribe "allProjects"

  Template.layout.events
    "click [data-action='toggleSidebar']": (e,t) ->
      #console.log "Toggling Sidebar"
      currentTarget = $(e.currentTarget)
      #console.log currentTarget
      sidebar = currentTarget.data("sidebar")
    "click #login":(e,t)->
      #console.log "Login clicked"
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
      #console.log "Signing out"
      Meteor.logout()
    "click .play":(e,t)->
      #console.log "Playing video"
      $(".video")[0].play()
      #height = $(".video").height()
      #$(".play").hide()
      #$(".about").css("margin-top",height)
    "mousedown, touchstart":(e,t)->
      #alert "MOUSEDOWN"
      #console.log "FUCKING MOUSEDOWN"
      clickMenu = $(".clickMenu")
      clickMenuTopMargin = 20
      clickMenuLeftMargin = 20
      window.clickMenuPosition = {}
      window.totalDistance = 0

      console.log "t: ",t
      console.log "this: ",this

      currentTarget = $(e.currentTarget)
      clickableTarget = currentTarget.closest(".clickable")

      menu = clickableTarget.attr("data-menu")
      console.log "menu: ",menu
      Session.set "menu",menu

      #console.log "starting check!"
      Session.set "clickMenuActive",true
      Session.set "focused",this._id

      x = e.pageX or e.originalEvent.pageX
      y = e.pageY or e.originalEvent.pageY

      #console.log "x: ",x
      #console.log "y: ",y

      #console.log "clickMenuTopMargin: ",clickMenuTopMargin
      #console.log "clickMenuLeftMargin: ",clickMenuLeftMargin
      $(".clickMenu").css
        transform: "translate3d(#{x-clickMenuLeftMargin}px,#{y-clickMenuTopMargin}px,0)"

      #Global probably isn't best, but it works for now.
      window.clickMenuTimeout = Meteor.setTimeout(()->
        #console.log "CLICKMENU TRIGGERED!"
        $(".clickMenu").addClass("activated")
        #Save mouse position globally
        window.clickMenuPosition.x = x
        window.clickMenuPosition.y = y
      ,200)

      #console.log "clickMenuTimeout: ",clickMenuTimeout
    "mouseover":(e,t)->
      #console.log "mouseover"
      #console.log "e: ",e
      #clickMenu = $(".clickMenu")

      #if clickMenu.hasClass("activated")
      #  currentTarget = $(e.currentTarget)
      #  console.log "currentTarget: ",currentTarget[0]
    "mousemove":(e,t)->
      #console.log "Follow the mouse as the user carries around the interface"
      #console.log "e:" ,e
      #Is the mouse held down?
      ###if e.which is 1
        #Calculate the mouse's total distance from the original clickMenuPosition
        clickMenuX = clickMenuPosition.x
        clickMenuY = clickMenuPosition.y
        x = e.pageX
        y = e.pageY
        clickMenuTopMargin = 20
        clickMenuLeftMargin = 20
        #console.log "clickMenuX: ",clickMenuX
        #console.log "clickMenuY: ",clickMenuY
        #console.log "currentX: ",currentX
        #console.log "currentY: ",currentY
        xDistance = x - clickMenuX
        xDistance = xDistance * xDistance
        #console.log "xDistance: ",xDistance
        yDistance = y - clickMenuY
        yDistance = yDistance * yDistance
        #console.log "yDistance: ",yDistance
        totalDistance = Math.round(Math.sqrt(xDistance+yDistance))
        #console.log "TotalDistance: ",totalDistance
        #If the total distance is greater than 110 pixels, reposition the clickMenu

        if totalDistance > 110
          #console.log "Repositioning!"
          $(".clickMenu").css
            transform: "translate3d(#{x-clickMenuLeftMargin}px,#{y-clickMenuTopMargin}px,0)"
          .one("webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend",() ->
            #console.log "TRANSITION ENDED!!!"
            window.clickMenuPosition.x = x
            window.clickMenuPosition.y = y
          )###
            #x: currentX - clickMenuLeftMargin
            #y: currentY - clickMenuTopMargin
            #duration: 20
            #complete: () ->
            #  console.log "ANIMATION COMPLETED! :3"
          #window.clickMenuPosition.x = x
          #window.clickMenuPosition.y = y


    "touchmove":(e,t)->
      #This is for handling mobile positioning
      #console.log "touchmoving!"
      Meteor.clearTimeout(clickMenuTimeout)
      clickMenu = $(".clickMenu")
      clickMenuTopMargin = 20
      clickMenuLeftMargin = 20

      x = e.originalEvent.pageX
      y = e.originalEvent.touches[0].clientY

      #console.log "y: ",y
      #console.log "e: ",e
      #console.log "lastY: ",lastY
      #console.log "MOVING"
      #console.log "changedTouches: ",e.originalEvent.changedTouches[0].clientY

      #currentY = e.originalEvent.touches[0].pageY

      #if oldY is newY
        #console.log "Events are the same, do stuff"
      #console.log "Moving"
      #else
      #  console.log "NO!!!"

      #If the clickMenu is open, prevent default scrolling
      if clickMenu.hasClass("activated")
        e.preventDefault()
        currentTarget = $(document.elementFromPoint(x,y))
        #console.log "currentTarget being hovered over: ",currentTarget
        #Only run if the element currently being hovered over by the user's finger has a parent of node
        unless currentTarget.parents(".node").length is 0
          node = currentTarget.parents(".node")
          #console.log "node: ",node
          #Add the hover event if the finger is over the node
          unless node.hasClass("origin")
            $(".node").removeClass("hovered")
            node.addClass("hovered")
      #else
      #  clickMenu.removeClass("activated")
      #lastY = y
      #console.log "lastY: ",lastY
    "mouseup, touchend":(e,t)->
      #console.log "mouseup"
      #Meteor.setTimeout(()->
      #console.log "clickMenuTimeout: ",clickMenuTimeout
      #Meteor.clearTimeout(clickMenuTimeout)
      $(".clickMenu").removeClass("activated")
      Session.set "focused",false
      Session.set "clickMenuActive",false
      #console.log "e: ",e
      #console.log "URGHHHHHH"
      #,100)
      #log "clickMenuTimeout ",clickMenuTimeout
      Meteor.clearTimeout(clickMenuTimeout)
    "mouseover .node":(e,t)->
      #console.log "MOUSEOVER NODE!"
      currentTarget = $(e.currentTarget)
      #console.log "currentTarget: ",currentTarget
      unless currentTarget.hasClass("origin")
        $(e.currentTarget).addClass("hovered")
    "mouseout .node":(e,t)->
      #console.log "MOUSEOUT NODE!"
      currentTarget = $(e.currentTarget)
      unless currentTarget.hasClass("origin")
        $(currentTarget).removeClass("hovered")
    "mouseup .node":(e,t)->
      #console.log "MOUSEUP ON A NODE!"
      currentTarget = $(e.currentTarget)
      action = currentTarget.data("action")
      window.totalDistance = 0
      console.log "action: ",action
      #Trigger different actions based on user input
      if action is "play"
        $(".video")[0].play()

if Meteor.isServer
  console.log "Server"
  #Publish Projects
  Meteor.publish "allProjects", ->
    Projects.find()

  #Populate Projects
  ###console.log "No Projects! Creating."
  Projects.insert
    previewSrc: ""
    title: "TITLE FROM SERVER"
    owner: "Server"###
