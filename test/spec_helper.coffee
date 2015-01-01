jsdom = require 'jsdom'
require 'mocha-sinon'

# move into beforeEach and flip global.window.close on to improve
# cleaning of environment during each test and prevent memory leaks
document = jsdom.jsdom('<html><head></head><body></body></html>', jsdom.level(1, 'core'))
global.document = document
global.window = document.parentWindow
global.navigator = document.parentWindow.navigator

beforeEach ->
    @document = document
    @window = document.parentWindow
