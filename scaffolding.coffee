#Handlebars Helpers
UI.registerHelper "focused", (context,value) ->
  #console.log "focusedThis",this
  #console.log "context:",context
  #console.log "Session.get('focused'):",Session.get("focused")
  #console.log "value",value
  #if Session.equals("test","focused")
  #  "focused"
  #else if Session.equals("test","blurred")
  #  "blurred"
  #console.log "focused",Session.get "focused"
  #console.log "context:",context
  if Session.equals("focused",context) and Session.equals("clickMenuActive",true) or Session.equals("property",context)
    #console.log "TRUUUUEEEEEE"
    console.log "context",context
    "focused"
  else if Session.equals("clickMenuActive",true) or Session.equals("editing",true)
    "blurred"
  else if Session.equals("hidden",true)
    "hidden"
  else
    "default"
UI.registerHelper "editing", (context,value) ->
  if Session.equals("editing",false) and !Session.equals("property",context) and context is undefined
    "hidden"
  else if Session.equals("editing",true) and Session.equals("property",context)
    "hidden"
  else
    "focused"
  #else if Session.equals("editing",false) and !Session.equals("property",undefined)
  #  "hidden"
  #if Session.equals("editing",false) and !Session.equals("property",undefined)
  #  console.log "Yes"
  #  "hidden"
  #else
  #  console.log "No"
  #  "focused"
UI.registerHelper "contentIs", (context,value)->
  videoSrc = Projects.findOne(Session.get("currentContent")).videoSrc
  console.log "videoSrc: ",videoSrc
  if videoSrc is context
    true
  else false
UI.registerHelper "menuIs", (context,value) ->
  Session.equals "menu",context
UI.registerHelper "routeIsContent", (context,value) ->
  current = Router.current()
  route = current.lookupTemplate() if current?
  if route is "contentAbout" or route is "contentCommunity"
    true
  else
    false
UI.registerHelper "routeIsProfile", (context,value) ->
  current = Router.current()
  route = current.lookupTemplate() if current?
  if route is "profileAbout" or route is "profileCommunity"
    true
  else
    false
UI.registerHelper "routeIsNot", (context,value) ->
  current = Router.current()
  route = current.lookupTemplate() if current?
  if route isnt context
    true
  else
    false
UI.registerHelper "cover", (context,value) ->
  if Session.equals "hidden",true
    "active"
  else
    "hidden"
UI.registerHelper "coverState", (context,value) ->
  #console.log "coverState"
  if Session.equals "coverState",context
    "active"
  else
    "hidden"
UI.registerHelper "coverStateIsnt", (context,value) ->
  if !Session.equals "coverState",context
    true
  else
    false
UI.registerHelper "Schema", (context,value) ->
  Schema
UI.registerHelper "serverError", (context,value) ->
  Session.get "serverError"
UI.registerHelper "serverErrorExists", (context,value) ->
  if !Session.equals "serverError",undefined
    "active"
  else
    "hidden"
UI.registerHelper "logoutError", (context,value) ->
  Session.get "logoutError"
UI.registerHelper "logoutErrorExists", (context,value) ->
  if !Session.equals "logoutError",undefined
    "active"
  else
    "hidden"
UI.registerHelper "clapperState", (context,value) ->
  Session.get "clapperState"
UI.registerHelper "loaded", (context,value) ->
  Session.get "loaded"

#Global Data Collections and Helpers
@Projects = new Meteor.Collection "projects"
@Topics = new Meteor.Collection "topics"
@Comments = new Meteor.Collection "comments"

#Projects Helpers

#Users Helpers
Meteor.users.helpers
  projects: ->
    Projects.find(owner:this._id)
@Schema = {}

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
    onBeforeAction: ->
      console.log "Change Famous Application Here!"
    waitOn: ->
      Subscriptions.projects
    data: ->
      console.log "Data!"
      projects: Projects.find(published:true)
    action: ->
      if this.ready()
        console.log "Ready!"
        this.render()
        Session.set "loaded",true
      else
        console.log "Waiting to load!"
    #data: ->
    #  console.log "ROUTER INITIALIZED!"
    #action: ->
    #  console.log "Action :)"
  @route "contentAbout",
    path: "/users/:owner/:content/about"
    #yieldTemplates:
    #  leftSidebar:
    #    to: "leftSidebar"
    #  rightSidebar:
    #    to: "rightSidebar"
    onBeforeAction: ->
      console.log "About Page"
      console.log "Change Famous Application Here!"
    data: ->
      params = @.params
      currentContent: Projects.findOne(params.content)
  @route "contentCommunity",
    path: "/users/:owner/:content/community"
    #yieldTemplates:
    #  leftSidebar:
    #    to: "leftSidebar"
    #  rightSidebar:
    #    to: "rightSidebar"
    onBeforeAction: ->
      console.log "Community Page"
      console.log "Change Famous Application Here!"
    data: ->
      params = @.params
      currentContent: Projects.findOne(params.content)
  @route "profileAbout",
    path: "/users/:owner/about"
    onBeforeAction: ->
      console.log "Profile Page"
      #console.log "@",@
    data: ->
      #console.log "Change Famous Application Here!"
      #console.log "@owner: ",@.params.owner
      params = @.params
      #console.log "params.owner:",params.owner
      user = Meteor.users.findOne(params.owner)
      #console.log "user",user
      #profileProjects: Projects.find()
      currentProfile: user
      projects: Projects.find()
  @route "profileCommunity",
    path: "/users/:owner/profileCommunity/:topic"
    onBeforeAction: ->
      console.log "Profile Community"
      console.log "Change Famous Application Here!"
    data: ->
      params = @.params
      user = Meteor.users.findOne(params.owner)
      currentProfile: user
      currentTopic: Topics.findOne(params.topic)
      childTopics: Comments.find(topic:params.topic,parent:null)
      topics: Topics.find(owner:params.owner)

#Form Validations (Client and Server)
#Specifiy the valid formats for data submitted from the signup form.
Schema.signupFormSchema = new SimpleSchema
  username:
    type: String
    label: "Username"
    optional: false
    min: 3
  email:
    type: String
    regEx: SchemaRegEx.Email
    label: "Email"
    optional: false
  password:
    type: String
    label: "Password"
    optional: false

#Customize output messages sent to the user when an error is come across.
Schema.signupFormSchema.messages
  required: "<div class='coverForm'>[label] is required!</div>"
  minString: "[label] must be at least [min] characters!"
  maxString: "[label] cannot exceed [max] characters!"
  minNumber: "[label] must be at least [min]!"
  maxNumber: "[label] cannot exceed [max]!"
  minDate: "[label] must be on or before [min]!"
  maxDate: "[label] cannot be after [max]!"
  minCount: "You must specify at least [minCount] values!"
  maxCount: "You cannot specify more than [maxCount] values!"
  noDecimal: "[label] must be an integer!"
  notAllowed: "[value] is not an allowed value!"
  expectedString: "[label] must be a string!"
  expectedNumber: "[label] must be a number!"
  expectedBoolean: "[label] must be a boolean!"
  expectedArray: "[label] must be an array!"
  expectedObject: "[label] must be an object!"
  expectedConstructor: "[label] must be a [type]!"
  regEx: "Whoa there buddy! Your [label] doesn't look right!"

#Specifiy the valid formats for data submitted from the login form.
Schema.loginFormSchema = new SimpleSchema
  usernameOrEmail:
    type: String
    optional: false
  password:
    type: String
    optional: false

#Customize output messages sent to the user when an error is come across.
Schema.loginFormSchema.messages
  required: "[label] is required!"
  minString: "[label] must be at least [min] characters!"
  maxString: "[label] cannot exceed [max] characters!"
  minNumber: "[label] must be at least [min]!"
  maxNumber: "[label] cannot exceed [max]!"
  minDate: "[label] must be on or before [min]!"
  maxDate: "[label] cannot be after [max]!"
  minCount: "You must specify at least [minCount] values!"
  maxCount: "You cannot specify more than [maxCount] values!"
  noDecimal: "[label] must be an integer!"
  notAllowed: "[value] is not an allowed value!"
  expectedString: "[label] must be a string!"
  expectedNumber: "[label] must be a number!"
  expectedBoolean: "[label] must be a boolean!"
  expectedArray: "[label] must be an array!"
  expectedObject: "[label] must be an object!"
  expectedConstructor: "[label] must be a [type]!"
  regEx: "Whoa there buddy! Your [label] doesn't look right!"

#Specifiy the valid formats for data submitted from the title form.
Schema.usernameFormSchema = new SimpleSchema
  username:
    type: String
    optional: false

#Customize output messages sent to the user when an error is come across.
Schema.usernameFormSchema.messages
  required: "[label] is required!"
  minString: "[label] must be at least [min] characters!"
  maxString: "[label] cannot exceed [max] characters!"
  minNumber: "[label] must be at least [min]!"
  maxNumber: "[label] cannot exceed [max]!"
  minDate: "[label] must be on or before [min]!"
  maxDate: "[label] cannot be after [max]!"
  minCount: "You must specify at least [minCount] values!"
  maxCount: "You cannot specify more than [maxCount] values!"
  noDecimal: "[label] must be an integer!"
  notAllowed: "[value] is not an allowed value!"
  expectedString: "[label] must be a string!"
  expectedNumber: "[label] must be a number!"
  expectedBoolean: "[label] must be a boolean!"
  expectedArray: "[label] must be an array!"
  expectedObject: "[label] must be an object!"
  expectedConstructor: "[label] must be a [type]!"
  regEx: "Whoa there buddy! Your [label] doesn't look right!"

#Specifiy the valid formats for data submitted from the title form.
Schema.roleFormSchema = new SimpleSchema
  "profile.role":
    type: String
    optional: false

#Customize output messages sent to the user when an error is come across.
Schema.roleFormSchema.messages
  required: "[label] is required!"
  minString: "[label] must be at least [min] characters!"
  maxString: "[label] cannot exceed [max] characters!"
  minNumber: "[label] must be at least [min]!"
  maxNumber: "[label] cannot exceed [max]!"
  minDate: "[label] must be on or before [min]!"
  maxDate: "[label] cannot be after [max]!"
  minCount: "You must specify at least [minCount] values!"
  maxCount: "You cannot specify more than [maxCount] values!"
  noDecimal: "[label] must be an integer!"
  notAllowed: "[value] is not an allowed value!"
  expectedString: "[label] must be a string!"
  expectedNumber: "[label] must be a number!"
  expectedBoolean: "[label] must be a boolean!"
  expectedArray: "[label] must be an array!"
  expectedObject: "[label] must be an object!"
  expectedConstructor: "[label] must be a [type]!"
  regEx: "Whoa there buddy! Your [label] doesn't look right!"

#Specifiy the valid formats for data submitted from the title form.
Schema.bioFormSchema = new SimpleSchema
  "profile.bio":
    type: String
    optional: false

#Customize output messages sent to the user when an error is come across.
Schema.bioFormSchema.messages
  required: "[label] is required!"
  minString: "[label] must be at least [min] characters!"
  maxString: "[label] cannot exceed [max] characters!"
  minNumber: "[label] must be at least [min]!"
  maxNumber: "[label] cannot exceed [max]!"
  minDate: "[label] must be on or before [min]!"
  maxDate: "[label] cannot be after [max]!"
  minCount: "You must specify at least [minCount] values!"
  maxCount: "You cannot specify more than [maxCount] values!"
  noDecimal: "[label] must be an integer!"
  notAllowed: "[value] is not an allowed value!"
  expectedString: "[label] must be a string!"
  expectedNumber: "[label] must be a number!"
  expectedBoolean: "[label] must be a boolean!"
  expectedArray: "[label] must be an array!"
  expectedObject: "[label] must be an object!"
  expectedConstructor: "[label] must be a [type]!"
  regEx: "Whoa there buddy! Your [label] doesn't look right!"

if Meteor.isClient
  #Default Session Variables
  Session.setDefault "coverState","info"
  Session.setDefault "clapperState","open"
  Session.setDefault "hidden",false
  Session.setDefault "editing",false
  Session.setDefault "property",null
  Session.setDefault "focused",null

  #Allow for fastclick on mobile devices
  window.addEventListener "load", (->
    FastClick.attach document.body
    return
  ), false

  #Handle Key Events
  $(document).keyup (e) ->
    key = e.which
    #If the escape key is pressed, disable hidden mode, only if we're not displaying a cover message to the user that can't be cancelled.
    unless Session.equals "coverState","message"
      if key is 27
        Session.set "hidden",false

  ###Template.profileCommunity.helpers
    childComments: () ->
      topic = this
      console.log "topic:",topic
      Comments.find
        topic:topic._id###

  Template.topic.helpers
    topicComments: () ->
      Comments.find
        parent: this._id

  #Handle Editor
  #Template.editor.rendered = () ->
  #  editor = this.$(".editor")[0]
  #  #console.log "editor",editor
  #  this._editor =
  #    new MediumEditor(
  #      editor
  #    ,
  #      disableToolbar: true
  #      cleanPastedHTML: true
  #      #disableDoubleReturn: true
  #    )

  Template.topic.rendered = () ->
    editor = this.$(".editor")[0]
    this._editor =
      new MediumEditor(
        editor
      ,
        disableToolbar:true
        disableDoubleReturn:true
      )
    #this._editor =
    #  new Medium
    #    element: editor
    #    mode: "rich"
    #    #autoHR: true

  #$(".editor").on("input",()->
  #  console.log "SANELY EDITING!"
  #)

  #Events
  Template.layout.events
    "input .editor":(e,t)->
      #Stop the event from bubbling
      e.preventDefault()
      e.stopImmediatePropagation()
      #console.log "Input!!!!!"
      #console.log "this",this
      self = this
      currentTarget = $(e.currentTarget)
      #console.log "currentTarget",currentTarget
      html = currentTarget.html()
      #console.log "html",html
      #Check for if it's a topic or a comment, and update accordingly.
      if self.topic
        #It's a comment, update the comment.
        Comments.update(
          self._id
        ,
          $set:
            body: html
        ,
          (err,result) ->
            if err
              console.log "err",err
            else
              console.log "result",result
        )
      else
        #It's a top level topic, update the topic.
        console.log "Top Level!"
        Topics.update(
          self._id
        ,
          $set:
            body: html
        ,
          (err,result) ->
            if err
              console.log "err",err
            else
              console.log "result",result
        )
    "mousedown":(e,t)->
      #alert "MOUSEDOWN"
      #console.log "FUCKING MOUSEDOWN"
      clickMenu = $(".clickMenu")
      clickMenuTopMargin = 20
      clickMenuLeftMargin = 20
      window.clickMenuPosition = {}
      window.totalDistance = 0

      #console.log "Mousedown:"
      #console.log "t: ",t
      #console.log "this: ",this

      currentTarget = $(e.currentTarget)
      clickableTarget = currentTarget.closest(".clickable")

      #console.log "mousedown currentTarget:",currentTarget

      menu = clickableTarget.attr("data-menu")
      #console.log "menu: ",menu
      Session.set "menu",menu

      href = clickableTarget.attr("data-href")
      if href
        #console.log "href: ",href
        Session.set "currentContent",href

      property = clickableTarget.attr("data-property")
      if property
        #console.log "property: ",property
        Session.set "property",property

      #Get the currentTarget type, ensure it's a paragragh, and check if it's parent is an editor
      if currentTarget.prop("tagName") is "P"
        console.log "P!"
        console.log "currentTarget",currentTarget[0]
        currentTarget.attr("data-editorContextId",Meteor.uuid())
        Session.set "editorContext",currentTarget.attr("data-editorContextId")


      #console.log "starting check!"
      #Session.set "clickMenuActive",true
      #console.log "Setting Session",this._id
      #Session.set "focused",this._id

      #console.log "this:",this

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
      window.clickMenuActivateTimeout = Meteor.setTimeout(()->
        Session.set "clickMenuActive",true
      ,100)

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


    ###"touchmove":(e,t)->
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
      #console.log "lastY: ",lastY###
    "mouseover .node":(e,t)->
      #console.log "MOUSEOVER NODE!"
      currentTarget = $(e.currentTarget)
      #console.log "currentTarget: ",currentTarget
      unless currentTarget.hasClass("origin")
        $(".outer").removeClass("hovered")
        #$(".dot").css
        #  width: 40
        #$(".dotInner").css
        #  width: 32
        $(e.currentTarget).addClass("hovered")
        #dot = currentTarget.find(".dot").first()
        #dotInner = currentTarget.find(".dotInner").first()
        #title = currentTarget.find(".title").first()
        #Set the width automatically so the text will display properly
        #console.log "title: ",title.outerWidth()
        #dot.css
        #  width: title.outerWidth() + 20 #Padding!
        #dotInner.css
        #  width: title.outerWidth() + 12 #Magic number for padding, yay.
    "mouseout .node":(e,t)->
      #console.log "MOUSEOUT NODE!"
      e.stopPropagation()
      #console.log "e: ",e
      currentTarget = $(e.currentTarget)
      #console.log currentTarget[0]
      parentNode = currentTarget.parents(".hovered")
      #console.log "parentNode: ",parentNode
      unless currentTarget.hasClass("origin")
        currentTarget.removeClass("hovered")
        #Shrink the parent when we move outside of the mouseout bounds
        #unless currentTarget.hasClass("inner")
        parentNode.removeClass("hovered")
    "mouseup .node":(e,t)->
      #console.log "MOUSEUP ON A NODE!"
      e.stopPropagation()
      currentTarget = $(e.currentTarget)
      action = currentTarget.data("action")
      window.totalDistance = 0
      #console.log "action: ",action
      #console.log "MouseUpThis:",this
      #console.log "t:",t
      #Trigger different actions based on user input
      if action is "create"
        if Meteor.user()
          user = Meteor.user()
          Projects.insert
            title: "My Film"
            body: "My First Film Content!"
            owner: Meteor.userId()
            published: false
          , (err, result) ->
            console.log "Insert callback!"
            if err
              console.log "err: ",err
            else
              console.log "Insert succeeded!"
              console.log "result: ",result
              Router.go "contentAbout",
                owner: Meteor.userId()
                content: result
              ###Meteor.users.update
                _id: Meteor.userId()
              ,
                $push:
                  "profile.projects": result###
      if action is "play"
        Router.go "about"
        #$(".video")[0].play()
      if action is "contentAbout"
        console.log "contentThis:",this
        #Grab the current content from the session variable
        params = Router.current().params
        content = Projects.findOne owner:params["owner"]
        console.log "content:",content
        Router.go "contentAbout",
          owner: content.owner
          content: content._id
        #$(".video")[0].pause()
      if action is "contentCommunity"
        params = Router.current().params
        content = Projects.findOne owner:params["owner"]
        Router.go "contentCommunity",
          owner: content.owner
          content: content._id
        #$(".video")[0].pause()
      if action is "edit"
        console.log "Doing editing stuff"
        Session.set "editing",true
      if action is "browse"
        Router.go "browse"
        #$(".video")[0].pause()
      if action is "profileAbout"
        Router.go "profileAbout",
          owner: Meteor.userId() if Meteor.user()?
        #$(".video")[0].pause()
      if action is "profileCommunity"
        params = Router.current().params
        mostRecentTopic = Topics.findOne(owner:params["owner"])
        Router.go "profileCommunity",
          owner: params["owner"]
          content: params["content"]
          topic: mostRecentTopic._id
        #$(".video")[0].pause()
      if action is "login"
        console.log "Login"
        Session.set "hidden",true
        Session.set "serverError",undefined
        Session.set "logoutError",undefined
        Session.set "coverState","login"
      if action is "signup"
        #console.log "Signup"
        Session.set "hidden",true
        #We want to reset the server error here because it shows up and is annoying otherwise.
        Session.set "serverError",undefined
        Session.set "logoutError",undefined
        Session.set "coverState","signup"
      if action is "logout"
        Session.set "clapperState","closed"
        Session.set "logoutError",undefined
        Session.set "hidden",true
        Meteor.logout(
          (err) ->
            if err
              console.log "error logging out!"
              console.log "err: ",err
              #Session.set "logoutError",err.reason
              Meteor.setTimeout(->
                Session.set "logoutError",err.reason
                Meteor.setTimeout(->
                  Session.set "hidden",false
                1500)
              500)
            else
              console.log "Logged out successfully!"
              Meteor.setTimeout(->
                Session.set "clapperState","open"
                Meteor.setTimeout(->
                  Session.set "hidden",false
                500)
              1000)
        )
      if action is "addPane"
        pane = {}
        pane.title = "Pane Title"
        pane.subtitle = "Pane Subtitle"
        pane.content = "Pane Content"
        console.log "pane:",pane
        #updateDoc = {}
        #updateDoc.$push = {}
        #console.log "updateDoc:",updateDoc
        Meteor.users.update(
          Meteor.userId()
        ,
          $push:
            "profile.panes": pane
        ,
          (err,result)->
            if err
              console.log "err:",err
            else
              console.log "result:",result
        )
      if action is "addMedia"
        console.log "addMedia"
        #console.log currentTarget
        editorContext = Session.get "editorContext"
        #console.log "editorContext",editorContext
        #Get the current editor Context element based on the session
        editorContextElem = $("[data-editorcontextid=#{editorContext}]")
        console.log "editorContextElem:",editorContextElem
        #Insert a DOM node after the editorContextElem
        editorContextElem.after("<div class='editorContent' style='background-image:url(http://i.imgur.com/Sjh1csr.png?1);'></div>")
        #Find the just inserted editorContent
        editorContent = editorContextElem.next(".editorContent")
        console.log "editorContent",editorContent
        #So that the user can have a paragraph to jump to, add an empty paragraph after the editorContent.
        #editorContent.after("<p></p>")
      if action is "addReply"
        console.log "addReply"
        console.log Session.get("focused")
    "mouseup":(e,t)->
      #console.log "mouseup"
      #Meteor.setTimeout(()->
      #console.log "clickMenuTimeout: ",clickMenuTimeout
      #Meteor.clearTimeout(clickMenuTimeout)
      $(".clickMenu").removeClass("activated")
      $(".node").removeClass("hovered")
      Session.set "focused",false
      Session.set "clickMenuActive",false
      #console.log "e: ",e
      #console.log "URGHHHHHH"
      #,100)
      #log "clickMenuTimeout ",clickMenuTimeout
      Meteor.clearTimeout(clickMenuActivateTimeout)
      Meteor.clearTimeout(clickMenuTimeout)

  #Router Subscriptions
  @Subscriptions =
    projects: Meteor.subscribe "allProjects"
    users: Meteor.subscribe "allUsers"
    topics: Meteor.subscribe "allTopics"
    comments: Meteor.subscribe "allComments"

  #AutoForm Settings
  AutoForm.setDefaultTemplate("plain")

  #Set up AutoForm Hooks
  AutoForm.hooks
    signupForm:
      onSubmit: (insertDoc,updateDoc,currentDoc) ->
        check(insertDoc,Schema.signupFormSchema)
        self = this
        console.log "signupForm validating!"
        console.log "insertDoc:",insertDoc
        console.log "updateDoc:",updateDoc
        console.log "currentDoc:",currentDoc
        Session.set "clapperState","open"
        Session.set "coverState","message"
        Accounts.createUser(
          insertDoc
        ,
          (err)->
            if err
              console.log "err: ",err
              Session.set "serverError",err.reason
              self.resetForm()
              Meteor.setTimeout(->
                Session.set "coverState","signup"
              1000)
            else
              console.log "Successfully signed up!"
              #Reset the form for future logins, and clear the serverError messages, if there are any
              self.resetForm()
              Session.set "serverError",undefined
              #If login or signup is successful, close the clapper, and hide the cover
              Meteor.setTimeout(->
                Session.set "clapperState","closed"
                #Close the cover
                Meteor.setTimeout(->
                  Session.set "hidden",false
                  #Session.set "clapperState","open"
                500)
              1000)
        )
        return false
    loginForm:
      onSubmit: (insertDoc,updateDoc,currentDoc) ->
        check(insertDoc,Schema.loginFormSchema)
        self = this
        Session.set "clapperState","open"
        Session.set "coverState","message"
        Meteor.loginWithPassword(
          insertDoc.usernameOrEmail
          insertDoc.password
        ,
          (err)->
            if err
              console.log "err: ",err
              Session.set "serverError",err.reason
              self.resetForm()
              Meteor.setTimeout(->
                Session.set "coverState","login"
              1000)
            else
              #log "Successfully logged in!"
              console.log "Successfully signed in!"
              self.resetForm()
              Session.set "serverError",undefined

              Meteor.setTimeout(->
                Session.set "clapperState","closed"
                Meteor.setTimeout(->
                  Session.set "hidden",false
                500)
              1000)
        )
        false
    usernameForm:
      onSubmit: (insertDoc,updateDoc,currentDoc) ->
        console.log "titleForm submitted!!!"
        console.log "insertDoc:",insertDoc
        console.log "updateDoc:",updateDoc
        console.log "currentDoc:",JSON.stringify(currentDoc)
        console.log "updateDocString:",JSON.stringify(updateDoc)
        console.log "this:",this
        Meteor.users.update
          _id: currentDoc._id
        ,
          updateDoc
        ,
          (err,result) ->
            if err
              console.log "err: ",err
            else
              console.log "result: ",result
              Session.set "editing",false
        false
    roleForm:
      onSubmit: (insertDoc,updateDoc,currentDoc) ->
        console.log "titleForm submitted!!!"
        console.log "insertDoc:",insertDoc
        console.log "updateDoc:",updateDoc
        console.log "currentDoc:",JSON.stringify(currentDoc)
        console.log "updateDocString:",JSON.stringify(updateDoc)
        console.log "this:",this
        Meteor.users.update
          _id: currentDoc._id
        ,
          updateDoc
        ,
          (err,result) ->
            if err
              console.log "err: ",err
            else
              console.log "result: ",result
              Session.set "editing",false
        false

if Meteor.isServer
  console.log "Server"
  #Publish Projects
  Meteor.publish "allProjects", ->
    Projects.find()

  Projects.allow
    insert: () ->
      true
    update: () ->
      true
    remove: () ->
      true

  Meteor.publish "allUsers", ->
    Meteor.users.find {},
      fields:
        emails: 0

  Meteor.users.allow
    insert: () ->
      true
    update: () ->
      true
    remove: () ->
      true

  Meteor.publish "allTopics", ->
    Topics.find()

  Topics.allow
    insert: () ->
      true
    update: () ->
      true
    remove: () ->
      true

  Meteor.publish "allComments", ->
    Comments.find()

  Comments.allow
    insert: () ->
      true
    update: () ->
      true
    remove: () ->
      true

  #We check the schema again on the server to be sure that we're not
  #Having calls bypassed via Accounts.CreateUser() from the client
  Schema.newUserSchema = new SimpleSchema
    username:
      type: String
      min: 3
    email:
      type: String
      regEx: SchemaRegEx.Email
      min: 3

  Accounts.onCreateUser (options, user) ->
    #log "Adding slug to user"
    #log "options: ",options
    console.log "user: ",user
    #user.ownerSlug = _.slugify user.username
    user.profile = {}
    user.profile.panes = []
    info = {}
    info.subtitle = "Newbie"
    info.body = "Learning the tricks of the trade!"
    user.profile.panes.push info
    user.profile.community = {}
    #user.profile.community.topics = []
    Topics.insert
      title: "What are you making next?"
      subtitle: user.username
      body: "What would you like to see next?"
      owner: user._id
    , (err, result) ->
      console.log "Insert callback!"
      if err
        console.log "err: ",err
      else
        console.log "Insert succeeded!"
        console.log "result: ",result
        #user.profile.community.topics.push result

    #user.profile.projects = []
    #user.profile = {}
    #user.profile.creations = []
    #user.profile.profileSrc = "/users/defaults/profileImage.png"
    #user.profile.profileCoverSrc = "/users/defaults/profileCover.png"
    #user.profile.description =
    #  "#{user.username} hasn't updated their default profile information yet, but we can rest assured that they shall surely do so in the near future by merely hovering over this text, clicking to edit it, and than typing whatever their hearts may desire. They just need to click elsewhere on the page and we'll handle the rest. Cheerio!"
    #user.profile.stripeCustomerId = undefined
    #user.profile.favorites = []
    #user.profile.following = []
    #user.profile.followers = []
    #user.profile.playing = undefined
    #user.profile.cinderAppSessions = []
    #log "user.ownerSlug: ",user.ownerSlug
    #We still want the default hook's 'profile' behavior.
    #if options.profile
    #  user.profile = options.profile
    user

  #Check that doc fits with business logic
  Accounts.validateNewUser (doc) ->
    console.log "validateNewUser called, checking business logic."
    #We input the values into a schema and test it against our
    #signupFormSchema to be sure the values are the same in both areas.
    userObject =
      username: doc.username
      email: doc.emails[0].address
    check(userObject,Schema.newUserSchema)
    console.log "Returning true?"
    true

  Accounts.validateNewUser (doc) ->
    console.log "Checking to see that gitolite isn't chosen as a username"
    console.log "doc: ",doc
    if doc.username.toLowerCase() is "gitolite"
      false
    else
      true
