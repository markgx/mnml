# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

Tweet = Backbone.Model.extend()

Tweets = Backbone.Collection.extend
  model: Tweet

tweets = new Tweets

TweetView = Backbone.View.extend
  tagName: 'li'

  render: ->
    $(@el).html($('#tweet-template').tmpl
      screen_name: @model.get('screen_name')
      tweet_text: @_linkify(@model.get('text'))
    )

    $(@el).data('statusId': @model.id)

  _linkify: (text) ->
    regex = /(https?:\/\/)([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?[^.\s]/
    text.replace(regex, '<a href="$&" target="_blank">$&</a>')

TimelineView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    if tweets.length > 0
      $ul = $('<ul>')
      $(@el).append($ul)

      tweets.each((t) ->
        tweetView = new TweetView(model: t)
        tweetView.render()
        $ul.append(tweetView.el)
      )

window.app =
  initialize: (initialTweets) ->
    _(initialTweets).each((t) ->
      tweets.add(new Tweet
        id: t.id
        text: t.text
        screen_name: t.screen_name
        full_name: t.full_name
      )
    )

    new TimelineView
      el: $('#timeline-view')
