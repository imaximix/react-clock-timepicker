React = require 'react'
TestUtils = require('react/addons').addons.TestUtils

TimePicker = require './time_picker'


describe 'TimePicker', ->

    beforeEach ->
        @onTimeChangeStub = @sinon.stub()
        @container = @document.createElement 'div'

    describe 'with default settings', ->

        beforeEach ->
            @timePickerView = TestUtils.renderIntoDocument <TimePicker />, @container
            @now = new Date()

        it 'should use the default hour hand radius', ->
            @timePickerView.state.hourHandRadius.should.eql 15

        it 'should use the default minute hand radius', ->
            @timePickerView.state.minuteHandRadius.should.eql 20

        it 'should use the default center point radius', ->
            @timePickerView.state.centerPointRadius.should.eql 10

        it 'should show clock face numbers', ->
            @timePickerView.state.areNumbersVisible.should.be.ok
            @timePickerView.getDOMNode().querySelectorAll('text').length.should.eql 24

        it 'should show the current hour', ->
            # uhh... sometimes when the test runs the time changes and we cry
            @timePickerView.state.hour.should.be.above @now.getHours() - 1
            @timePickerView.state.hour.should.be.below @now.getHours() + 1

        it 'should show the current minute', ->
            @timePickerView.state.minute.should.be.above @now.getMinutes() - 1
            @timePickerView.state.minute.should.be.below @now.getMinutes() + 1

        describe 'and after mounting;', ->

            beforeEach ->
                svgNode = @timePickerView.refs.svgContainer.getDOMNode()
                svgNode.offsetWidth = 500
                svgNode.offsetHeight = 500

                @resizeStub = @sinon.stub window, 'addEventListener'

                @timePickerView.componentDidMount()

            afterEach ->
                @resizeStub.restore()

            it 'attaches to the resize event on the document', ->
                @resizeStub.args[0][0].should.eql 'resize'
                @resizeStub.args[0][1].should.eql @timePickerView.setCenter

            it 'finds the correct center point', ->
                @timePickerView.state.xCenter.should.eql 250
                @timePickerView.state.yCenter.should.eql 250

            it 'sets the clock radius', ->
                @timePickerView.state.clockRadius.should.be.ok

        describe 'after window resized to be more wide than tall;', ->

            beforeEach ->
                svgNode = @timePickerView.refs.svgContainer.getDOMNode()
                svgNode.offsetWidth = 700
                svgNode.offsetHeight = 400

                resizeEvent = @document.createEvent('HTMLEvents')
                resizeEvent.initEvent('resize')
                @window.dispatchEvent(resizeEvent)

            it 'sets the clock width the half the height', ->
                @timePickerView.state.clockRadius.should.eql 200

            it 'sets the xCenter to half the width', ->
                @timePickerView.state.xCenter.should.eql 350

            it 'sets the yCenter to half the height', ->
                @timePickerView.state.yCenter.should.eql 200

        describe 'after window resized to be more tall than wide;', ->

            beforeEach ->
                svgNode = @timePickerView.refs.svgContainer.getDOMNode()
                svgNode.offsetWidth = 400
                svgNode.offsetHeight = 700

                resizeEvent = @document.createEvent('HTMLEvents')
                resizeEvent.initEvent('resize')
                @window.dispatchEvent(resizeEvent)

            it 'sets the clock width the half the height', ->
                @timePickerView.state.clockRadius.should.eql 200

            it 'sets the xCenter to half the width', ->
                @timePickerView.state.xCenter.should.eql 200

            it 'sets the yCenter to half the height', ->
                @timePickerView.state.yCenter.should.eql 350

    describe 'with custom settings', ->

        beforeEach ->
            @timePickerView = TestUtils.renderIntoDocument(
                <TimePicker
                    hour=12
                    minute=43
                    onTimeChange={ @onTimeChangeStub }
                    areNumbersVisible=false
                    numberPadding=10
                    hourHandRadius=50
                    minuteHandRadius=100
                    centerPointRadius=0
                />,
                @container
            )

        it 'has a custom hour hand radius', ->
            @timePickerView.state.hourHandRadius.should.eql 50

        it 'has a custom minute hand radius', ->
            @timePickerView.state.minuteHandRadius.should.eql 100

        it 'has a custom center point radius', ->
            @timePickerView.state.centerPointRadius.should.eql 0

        it 'does not show clock face numbers', ->
            @timePickerView.state.areNumbersVisible.should.not.be.ok
            @timePickerView.getDOMNode().querySelectorAll('text').length.should.not.be.ok

        it 'should set the custom time', ->
            @timePickerView.state.hour.should.eql 12
            @timePickerView.state.minute.should.eql 43

        it 'sets the handle rotation appropriately', ->
            @timePickerView.state.hourRotation.should.eql 12 * 30
            @timePickerView.state.minuteRotation.should.eql (43/5) * 30

    describe 'on unmount', ->

        beforeEach ->
            @timePickerView = TestUtils.renderIntoDocument <TimePicker />, @container
            @resizeSpy = @sinon.spy window, 'removeEventListener'
            @timePickerView.unmountComponent()

        afterEach ->
            @resizeSpy.restore()

        it 'should remove the resize handler', ->
            @resizeSpy.args[0][0].should.eql 'resize'
            @resizeSpy.args[0][1].should.eql @timePickerView.setCenter

    describe 'toggling ampm', ->

        beforeEach ->
            @timePickerView = TestUtils.renderIntoDocument <TimePicker hour=12 minute=0 />, @container

        it 'switches from pm to am', ->
            @timePickerView.setState
                hour: 12
                isPM: true

            @timePickerView.forceUpdate()

            @timePickerView.handleAM()

            @timePickerView.state.hour.should.eql 0
            @timePickerView.state.isPM.should.not.be.ok

        it 'switches from am to pm', ->
            @timePickerView.setState
                hour: 0
                isPM: false
            @timePickerView.forceUpdate()

            @timePickerView.handlePM()

            @timePickerView.state.hour.should.eql 12
            @timePickerView.state.isPM.should.be.ok

    describe 'handle', ->

        beforeEach ->
            @onTimeChangeStub = @sinon.stub()
            @timePickerView = TestUtils.renderIntoDocument <TimePicker hour=12 minute=0 onTimeChange={@onTimeChangeStub} />, @container

        describe 'drag start', ->

            beforeEach ->
                @e =
                    preventDefault: @sinon.stub()
                @eventListenerSpy = @sinon.spy document, 'addEventListener'
                @timePickerView.handleDragStart(@e)

            afterEach ->
                @eventListenerSpy.restore()

            it 'calls preventDefault', ->
                @e.preventDefault.called.should.be.ok

            it 'puts itself in a dragable state', ->
                @timePickerView.isDraggable.should.be.ok

            it 'attaches to the document for move and release events', ->
                @eventListenerSpy.args[0][0].should.eql 'mouseup'
                @eventListenerSpy.args[0][1].should.eql @timePickerView.handleDragStop
                @eventListenerSpy.args[1][0].should.eql 'mousemove'
                @eventListenerSpy.args[1][1].should.eql @timePickerView.handleDrag
                @eventListenerSpy.args[2][0].should.eql 'touchend'
                @eventListenerSpy.args[2][1].should.eql @timePickerView.handleDragStop
                @eventListenerSpy.args[3][0].should.eql 'touchmove'
                @eventListenerSpy.args[3][1].should.eql @timePickerView.handleDrag

        describe 'drag end', ->

            beforeEach ->
                @e =
                    preventDefault: @sinon.stub()
                @eventListenerSpy = @sinon.spy document, 'removeEventListener'
                @timePickerView.handleDragStop(@e)

            afterEach ->
                @eventListenerSpy.restore()

            it 'calls preventDefault', ->
                @e.preventDefault.called.should.be.ok

            it 'removes itself from a dragable state', ->
                @timePickerView.isDraggable.should.not.be.ok

            it 'attaches to the document for move and release events', ->
                @eventListenerSpy.args[0][0].should.eql 'mouseup'
                @eventListenerSpy.args[0][1].should.eql @timePickerView.handleDragStop
                @eventListenerSpy.args[1][0].should.eql 'mousemove'
                @eventListenerSpy.args[1][1].should.eql @timePickerView.handleDrag
                @eventListenerSpy.args[2][0].should.eql 'touchend'
                @eventListenerSpy.args[2][1].should.eql @timePickerView.handleDragStop
                @eventListenerSpy.args[3][0].should.eql 'touchmove'
                @eventListenerSpy.args[3][1].should.eql @timePickerView.handleDrag

            it 'updates the parent', ->
                obj = @onTimeChangeStub.args[0][0]
                obj.hour.should.eql 12
                obj.minute.should.eql 0
                obj.isPM.should.be.ok

        describe 'drag move', ->

            beforeEach ->
                @timePickerView.setState
                    currentDragType: 'hour'
                    xCenter: 0
                    yCenter: 0

                @e =
                    preventDefault: @sinon.stub()
                    stopPropagation: @sinon.stub()
                    clientX: 1
                    clientY: 0
                @timePickerView.handleDragStart(@e)
                @timePickerView.handleDrag(@e, 1)

            afterEach ->
                @timePickerView.handleDragStop(
                    preventDefault: @sinon.stub()
                )

            it 'calls preventDefault', ->
                @e.preventDefault.callCount.should.eql 2

            it 'calls stopPropogation', ->
                @e.stopPropagation.callCount.should.eql 1

            it 'sets the hour hand rotation', ->
                @timePickerView.state.hourRotation.should.eql 90

            it 'sets the hour', ->
                @timePickerView.state.hour.should.eql 15 # 3pm

            it 'hides the minute text', ->
                @timePickerView
                    .getDOMNode()
                    .querySelectorAll('.time-picker__numbers--hidden.time-picker__numbers--minute')
                    .length.should.eql 12

            it 'shows the hour text', ->
                @timePickerView
                    .getDOMNode()
                    .querySelectorAll('.time-picker__numbers--hidden.time-picker__numbers--hour')
                    .length.should.eql 0

                @timePickerView
                    .getDOMNode()
                    .querySelectorAll('.time-picker__numbers.time-picker__numbers--hour')
                    .length.should.eql 12

            it 'scales the hour handle up', ->
                @timePickerView.refs.hourHandle.getDOMNode()
                    .attributes.transform.textContent
                    .indexOf('scale(1.1)').should.not.eql -1

            it 'keeps minute handle the standard size', ->
                @timePickerView.refs.minuteHandle.getDOMNode()
                    .attributes.transform.textContent
                    .indexOf('scale(1)').should.not.eql -1

        describe 'drag move the minute hand', ->

            beforeEach ->
                @timePickerView.setState
                    currentDragType: 'minute'
                    xCenter: 0
                    yCenter: 0

                @e =
                    preventDefault: @sinon.stub()
                    stopPropagation: @sinon.stub()
                    clientX: 1
                    clientY: 0
                @timePickerView.handleDragStart(@e)
                @timePickerView.handleDrag(@e)

            afterEach ->
                @timePickerView.handleDragStop(
                    preventDefault: @sinon.stub()
                )

            it 'calls preventDefault', ->
                @e.preventDefault.callCount.should.eql 2

            it 'calls stopPropogation', ->
                @e.stopPropagation.callCount.should.eql 1

            it 'sets the minute hand rotation', ->
                @timePickerView.state.minuteRotation.should.eql 90

            it 'sets the minute', ->
                @timePickerView.state.minute.should.eql 15

            it 'reveals the minutes text', ->
                @timePickerView
                    .getDOMNode()
                    .querySelectorAll('.time-picker__numbers--hidden.time-picker__numbers--minute')
                    .length.should.eql 0

                @timePickerView
                    .getDOMNode()
                    .querySelectorAll('.time-picker__numbers.time-picker__numbers--minute')
                    .length.should.eql 12

            it 'hides the hours text', ->
                @timePickerView
                    .getDOMNode()
                    .querySelectorAll('.time-picker__numbers--hidden.time-picker__numbers--hour')
                    .length.should.eql 12

            it 'scales the minute handle up', ->
                @timePickerView.refs.minuteHandle.getDOMNode()
                    .attributes.transform.textContent
                    .indexOf('scale(1.1)').should.not.eql -1

            it 'keeps hour handle the standard size', ->
                @timePickerView.refs.hourHandle.getDOMNode()
                    .attributes.transform.textContent
                    .indexOf('scale(1)').should.not.eql -1
