React = require 'react'


ROTATION_UNIT = 30
ROTATION_UNIT_RADIANS = ROTATION_UNIT * (Math.PI / 180)


module.exports = React.createClass

    getInitialState: ->
        now = new Date()
        startingHour = if @props.hour? then @props.hour else now.getHours()
        startingMinute = if @props.minute? then @props.minute else (now.getMinutes())

        # whoa! that is a lot of state! is that bad? *shrug*
        hour: startingHour
        hourRotation: startingHour * ROTATION_UNIT
        hourHandRadius: if @props.hourHandRadius? then @props.hourHandRadius else 15
        minute: startingMinute
        minuteRotation: (startingMinute / 5) * ROTATION_UNIT
        minuteHandRadius: if @props.minuteHandRadius? then @props.minuteHandRadius else 20

        isPM: startingHour >= 12

        # stylistic
        areNumbersVisible: if @props.areNumbersVisible? then @props.areNumbersVisible else true
        numberPadding: if @props.numberPadding? then @props.numberPadding else 20
        centerPointRadius: if @props.centerPointRadius? then @props.centerPointRadius else 10

        # starting values
        clockRadius: 0
        xCenter: 0
        yCenter: 0

    setCenter: ->
        svgNode = @refs.svgContainer.getDOMNode()

        if svgNode.offsetHeight > svgNode.offsetWidth
            clockRadius = svgNode.offsetWidth / 2
        else
            clockRadius = svgNode.offsetHeight / 2

        @setState
            xCenter: svgNode.offsetWidth / 2
            yCenter: svgNode.offsetHeight / 2
            clockRadius: clockRadius

    componentDidMount: ->
        window.addEventListener 'resize', @setCenter
        @setCenter()

        # guarentee correct sizing after init
        setTimeout @setCenter, 0

    componentWillUnmount: ->
        window.removeEventListener 'resize', @setCenter

    handleDragStart: (e) ->
        e.preventDefault();

        @isDraggable = true

        # svgNode = @refs.svgContainer.getDOMNode()
        # we were at one time not using document, the problem is that if your finger
        # or mouse leave the svgNode area then listeners won't get removed and life will be sad
        document.addEventListener 'mouseup', @handleDragStop
        document.addEventListener 'mousemove', @handleDrag
        document.addEventListener 'touchend', @handleDragStop
        document.addEventListener 'touchmove', @handleDrag

    handleDragStop: (e) ->
        e.preventDefault();
        @isDraggable = false

        # svgNode = @refs.svgContainer.getDOMNode()
        # see comment in handleDragStart method
        document.removeEventListener 'mouseup', @handleDragStop
        document.removeEventListener 'mousemove', @handleDrag
        document.removeEventListener 'touchend', @handleDragStop
        document.removeEventListener 'touchmove', @handleDrag

        @setState
            'currentDragType': ''

        @triggerTimeUpdate()

    triggerTimeUpdate: ->
        @props.onTimeChange?(
            hour: @state.hour
            minute: @state.minute
            isPM: @state.isPM
        )

    findAngle: (center, point) ->
        delta =
            x: center.x - point.x
            y: center.y - point.y

        aR = Math.atan2 -delta.x, delta.y

        aR * (180 / Math.PI)

    handleDrag: (e) ->
        e.preventDefault()

        if not @isDraggable
            return

        e.stopPropagation()

        center =
            x: @state.xCenter
            y: @state.yCenter

        mouse =
            x: if e.clientX? then e.clientX else e.touches?[0].clientX
            y: if e.clientY? then e.clientY else e.touches?[0].clientY

        angle = @findAngle center, mouse

        state = {}

        # update the rotation angle
        # make the direction positive
        directionSigned = Math.round(angle / ROTATION_UNIT)
        direction = (if directionSigned <= 0 then directionSigned + 12 else directionSigned) % 12
        state[@state.currentDragType + "Rotation"] = direction * ROTATION_UNIT

        # update the time
        if @state.currentDragType == 'minute'
            state[@state.currentDragType] = direction * 5
        else
            if @state.isPM
                state[@state.currentDragType] = direction + 12
            else
                state[@state.currentDragType] = direction

        @setState state

    handleHourDragStart: (e) ->
        @setState
            'currentDragType': 'hour'
        @handleDragStart(e)

    handleMinuteDragStart: (e) ->
        @setState
            'currentDragType': 'minute'
        @handleDragStart(e)

    _drawNumber: (number, type)->
        angle = (number * ROTATION_UNIT_RADIANS) + (Math.PI/2) # plus 90deg aka pi/2
        xTranslation = (@state.clockRadius - @state.numberPadding) * Math.cos(angle)
        yTranslation = (@state.clockRadius - @state.numberPadding) * Math.sin(angle)

        modifierClassName = ''

        if type == 1
            number *= 5
            modifierClassName = 'time-picker__numbers--hidden'

        if @state.currentDragType == 'minute' and type == 1
            modifierClassName = ''

        if @state.currentDragType == 'minute' and type != 1
            modifierClassName = 'time-picker__numbers--hidden'

        if type == 0
            modifierClassName += ' time-picker__numbers--hour'
        else
            modifierClassName += ' time-picker__numbers--minute'

        <text
            x="#{ @state.xCenter - xTranslation }"
            y="#{ @state.yCenter - yTranslation }"
            key={ number }
            className="time-picker__numbers #{ modifierClassName }"
        >
            { number }
        </text>

    drawHour: (number) ->
        @_drawNumber(number, 0)

    drawMinute: (number) ->
        @_drawNumber(number, 1)

    handleAM: ->
        hour = @state.hour
        if @state.hour >= 12
            hour = @state.hour - 12

        @setState
            'isPM': false
            'hour': hour

        # triggerTimeUpdate really depends on the state. We need the state to change
        # immediately... this state can be safely overriden though
        @state.hour = hour
        @state.isPM = false

        @triggerTimeUpdate()

    handlePM: ->
        hour = @state.hour
        if @state.hour < 12
            hour = @state.hour + 12

        @setState
            'isPM': true
            'hour': hour

        # triggerTimeUpdate really depends on the state... we need the state to change
        # immediately... this state can be safely overriden though
        @state.hour = hour
        @state.isPM = true

        @triggerTimeUpdate()

    render: ->
        hourHandleScale = if @state.currentDragType == 'hour' then 1.1 else 1
        minuteHandleScale = if @state.currentDragType == 'minute' then 1.1 else 1

        minuteArmY2 = @state.yCenter - @state.clockRadius * .75
        hourArmY2 = @state.yCenter - @state.clockRadius * .5

        minuteHandlePosition =
            x: @state.xCenter
            y: minuteArmY2 + @state.minuteHandRadius * 1.5

        hourHandlePosition =
            x: @state.xCenter
            y: hourArmY2 + @state.hourHandRadius * 1.5

        <time className="time-picker">
            <svg ref="svgContainer" className="time-picker__clock">
                <circle
                    className="time-picker__face"
                    cx="#{ @state.xCenter }"
                    cy="#{ @state.yCenter }"
                    r="#{ @state.clockRadius }"
                />
                <circle
                    className="time-picker__center-point"
                    cx="#{ @state.xCenter }"
                    cy="#{ @state.yCenter }"
                    r={ @state.centerPointRadius }
                />
                <line
                    className="time-picker__arm time-picker__arm--minute"
                    x1="#{ @state.xCenter }"
                    y1="#{ @state.yCenter }"
                    x2="#{ @state.xCenter }"
                    y2="#{ minuteArmY2 }"
                    transform="rotate(#{ @state.minuteRotation }, #{ @state.xCenter }, #{ @state.yCenter })"
                    onMouseDown={ @handleMinuteDragStart }
                    onTouchStart={ @handleMinuteDragStart }
                />
                <circle
                    className="time-picker__handle time-picker__handle--minute"
                    ref="minuteHandle"
                    cx="#{ minuteHandlePosition.x }"
                    cy="#{ minuteHandlePosition.y }"
                    r={ @state.minuteHandRadius }
                    transform="rotate(#{ @state.minuteRotation }, #{ @state.xCenter }, #{ @state.yCenter }) translate(#{-1 * @state.xCenter * (minuteHandleScale - 1) }, #{-1 * minuteHandlePosition.y * (minuteHandleScale - 1) }) scale(#{minuteHandleScale})"
                    onMouseDown={ @handleMinuteDragStart }
                    onTouchStart={ @handleMinuteDragStart }
                />
                <line
                    className="time-picker__arm time-picker__handle--hour"
                    x1="#{ @state.xCenter }"
                    y1="#{ @state.yCenter }"
                    x2="#{ @state.xCenter }"
                    y2="#{ hourArmY2 }"
                    onMouseDown={ @handleHourDragStart }
                    onTouchStart={ @handleHourDragStart }
                    transform="rotate(#{ @state.hourRotation }, #{ @state.xCenter }, #{ @state.yCenter })"
                />
                <circle
                    className="time-picker__handle time-picker__handle--hour"
                    ref="hourHandle"
                    cx="#{ hourHandlePosition.x }"
                    cy="#{ hourHandlePosition.y }"
                    r={ @state.hourHandRadius }
                    onMouseDown={ @handleHourDragStart }
                    onTouchStart={ @handleHourDragStart }
                    transform="rotate(#{ @state.hourRotation }, #{ @state.xCenter }, #{ @state.yCenter }) translate(#{-1 * @state.xCenter * (hourHandleScale - 1) }, #{-1 * hourHandlePosition.y * (hourHandleScale - 1) }) scale(#{hourHandleScale})"
                />
                <g className="time-picker__hours">
                    { if @state.areNumbersVisible then [1..12].map(@drawHour) else '' }
                </g>
                <g className="time-picker__minutes">
                    { if @state.areNumbersVisible then [0..11].map(@drawMinute) else '' }
                </g>
            </svg>
            <nav className="time-picker__ampm">
                <button
                    className="time-picker__ampm__toggle time-picker__am #{ if not @state.isPM then 'time-picker__ampm__toggle--active' else '' }"
                    ref="amButton"
                    onClick={ @handleAM }
                    onTouchEnd={ @handleAM }
                >
                    AM
                </button>
                <button
                    className="time-picker__ampm__toggle time-picker__pm #{ if @state.isPM then 'time-picker__ampm__toggle--active' else '' }"
                    ref="pmButton"
                    onClick={ @handlePM }
                    onTouchEnd={ @handlePM }
                >
                    PM
                </button>
            </nav>
        </time>
