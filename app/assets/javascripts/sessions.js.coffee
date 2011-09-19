# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

TimelineView = Backbone.View.extend
  initialize: ->
    console.debug('TODO: do something')

window.app =
  initialize: ->
    new TimelineView
