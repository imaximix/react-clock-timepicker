[![Build Status](https://secure.travis-ci.org/parris/react-android-timepicker.png)](http://travis-ci.org/parris/react-android-timepicker)

React Android TimePicker Component
==================================

An android inspired calendar time picker implemented in ReactJS

Usage
-----

    React = require('react');

    TimePicker = require('../time_picker');

    document.addEventListener('DOMContentLoaded', function() {

        React.render(
            <TimePicker onTimeChange={console.log} />,
            document.body
        );
    });

Alternatively if you supply a ref, you can get `hour`, `minute` and `isPM` from
the `state` (see example/main.coffee) for an example.

CSS
---

- I included a basic stylesheet. I'm using a different stylesheet in my app.
- You could include the css file directly or import the less/scss files
- We are using BEM. In short, time-picker is the name of the component, __arm is contained within it. __arm--hour is a variation on the arm.
- Here's the full list of class names, you can tweak the SVG styles using css:
    - time-picker
    - time-picker__clock
    - time-picker__arm
        - time-picker__arm--hour
        - time-picker__arm--minute
    - time-picker__handle
        - time-picker__handle--hour
        - time-picker__handle--minute
    - time-picker__face
    - time-picker__center-point
    - time-picker__hours (group containing hour numbers)
    - time-picker__minutes (group containing minute numbers)
    - time-picker__numbers
        - time-picker__numbers--hidden (when not active)
        - time-picker__numbers--hour
        - time-picker__numbers--minute
    - time-picker__ampm
        - time-picker__ampm__toggle
        - time-picker__ampm__toggle--active
        - time-picker__am
        - time-picker__pm

Options
-------

    name                default    description
    ------------------------------------------------------------------------------------

    hour                - current  - starting hour (24 hour based)
    minute              - current  - starting minute
    onTimeChange        - optional - if specified it'll get called when the time changes

    areNumbersVisible   - true     - should show clock numbers

    # unfortunately, some things can't be controlled via CSS easily
    # pull requests welcome!
    numberPadding       - 20       - padding from the edge of the clock for each number
    hourHandRadius      - 20       - radius of the hour hand circle
    minuteHandRadius    - 15       - radius of minute hand circle
    centerPointRadius   - 10       - radius of the center point circle

Demo
----

Blog post: [http://parrisneeds.coffee/2014/12/25/react-timepicker/](http://parrisneeds.coffee/2014/12/25/react-timepicker/)

To try out the example yourself:

1. clone the repo
2. npm install (this might fail, but its ok)
3. `npm install react`
4. `npm test`
5. run `npm run-script build-example`
6. open example/index.html


Compatibility
-------------

Requires a version of React to be installed:
- Tested a bit with react ~0.10.0
- Developed using react ~0.12.0

Requires Browsers with SVG: IE9+

Animations Require CSS3, but should be ignored otherwise

Task List
---------

Contributions welcome but require unit tests!

- 24 clock mode (android does implement this)
- Add some material design effects when tapping on the circles
  - A flash on tap of the handles
  - Animate scaling

Contribution Notes
------------------

- you need manually `npm install react` and uninstall it before you `npm link`
    - does anyone know how to make this less annoying?
- the main time_picker.js file is generated on prepublish
- .less/.scss files are created from the .css file on prepubish
- example/main.js is gitignored and needs to be manually created
- your code will run through travis-ci

