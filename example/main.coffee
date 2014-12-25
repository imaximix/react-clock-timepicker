React = require 'react'

# must use .coffee or weird things ensue...
TimePicker = require '../time_picker.coffee'

MyComponent = React.createClass

    componentDidMount: ->
        window.timePicker = @refs.timePicker

    log: (dateInfo) ->
        console.log dateInfo

    render: ->
        # can't just use console.log in place of @log, Illegal Invocation womp womp
        <TimePicker ref="timePicker" onTimeChange={ @log } />

document.addEventListener 'DOMContentLoaded', ->
    React.render(
        <MyComponent />,
        document.body
    )
