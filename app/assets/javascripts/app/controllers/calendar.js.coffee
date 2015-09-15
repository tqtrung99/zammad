class Index extends App.ControllerContent
  events:
    'click .js-new':         'newDialog'
    'click .js-description': 'description'

  hours: {
    mon: {
      active: true
      timeframes: ['09:00-17:00']
    }
    tue: {
      active: true
      timeframes: ['00:00-24:00']
    }
    wed: {
      active: true
      timeframes: ['09:00-17:00']
    }
    thu: {
      active: true
      timeframes: ['09:00-12:00', '13:00-17:00']
    }
    fri: {
      active: true
      timeframes: ['09:00-17:00']
    }
    sat: {
      active: false
      timeframes: ['10:00-14:00']
    }
    sun: {
      active: false
      timeframes: ['10:00-14:00']
    }
  }

  constructor: ->
    super

    # check authentication
    return if !@authenticate()

    @subscribeId = App.Calendar.subscribe(@render)
    App.Calendar.fetch()

  render: =>
    calendars = App.Calendar.search(
      sortBy: 'name'
    )
    for calendar in calendars

      # get preview public holidays
      public_holidays_preview = {}
      if calendar.public_holidays
        from = new Date().setTime(new Date().getTime() - (5*24*60*60*1000))
        till = new Date().setTime(new Date().getTime() + (70*24*60*60*1000))
        keys = Object.keys(calendar.public_holidays).reverse()
        #for day, comment of calendar.public_holidays
        for day in keys
          itemTime = new Date( Date.parse( "#{day}T00:00:00Z" ) )
          if itemTime < till && itemTime > from
            public_holidays_preview[day] = calendar.public_holidays[day]
      calendar.public_holidays_preview = public_holidays_preview

    # show description button, only if content exists
    showDescription = false
    if App.Calendar.description
      if !_.isEmpty(calendars)
        showDescription = true
      else
        description = marked(App[ @genericObject ].description)

    @html App.view('calendar/index')(
      calendars:       calendars
      showDescription: showDescription
      description:     description
    )

  release: =>
    if @subscribeId
      App.Calendar.unsubscribe(@subscribeId)

  newDialog: =>
    @newItemModal = new App.ControllerModal
      large: true
      head: 'New Calendar'
      content: App.view('calendar/new')()
      button: 'Create'
      shown: true
      cancel: true
      container: @el.closest('.content')
      onShown: =>
        businessHours = new App.BusinessHours
          hours: @hours

        businessHours.render()

        @el.closest('.content').find('.js-business-hours').html(businessHours.el)

  description: (e) =>
    new App.ControllerGenericDescription(
      description: App.Calendar.description
      container:   @el.closest('.content')
    )

App.Config.set( 'Calendars', { prio: 2400, name: 'Calendars', parent: '#manage', target: '#manage/calendars', controller: Index, role: ['Admin'] }, 'NavBarAdmin' )