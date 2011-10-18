Tweet = Backbone.Model.extend()

Tweets = Backbone.Collection.extend
  model: Tweet

  comparator: (tweet) ->
    tweet.get('id')

tweets = new Tweets

TweetView = Backbone.View.extend
  tagName: 'li'

  render: ->
    $(@el).html($('#tweet-template').tmpl
      screen_name: @model.get('data').user.screen_name
      tweet_text: @_linkify(@model.get('data').text)
      created_at: (new Date(@model.get('data').created_at)).toISOString()
    )

    $(@el).data('statusId': @model.id)

  _linkify: (text) ->
    regex = /(https?:\/\/)([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?[^.\s]/
    text.replace(regex, '<a href="$&" target="_blank">$&</a>')

TimelineView = Backbone.View.extend
  initialize: ->
    tweets.bind('add', @addTweet, this)

  events:
    'keyup #compose-field': 'editingComposeField'
    'click #tweet-button': 'sendTweet'

  addTweet: (tweet) ->
    tweetView = new TweetView(model: tweet)
    tweetView.render()
    @$('ul').append(tweetView.el)

  editingComposeField: (e) ->
    count = $(e.currentTarget).val().length
    @$('#remaining-chars').text("#{140 - count} remaining")

  sendTweet: ->
    $.post('/tweets', { 'tweet': @$('#compose-field').val() }, (data) =>
      @$('#compose-field').val('')
      @$('#remaining-chars').text('140 remaining')
      @getNewTweets()
    ).error(->
      alert 'There was an error posting your tweet.'
    )

  getNewTweets: ->
    sinceId = null

    if tweets.length > 0
      sinceId = tweets.at(tweets.length - 1).id

    $.get('/tweets', { sinceId: sinceId }, (data) ->
      newTweets = data.reverse()
      _(newTweets).each((t) ->
        tweets.add(new Tweet
          id: t.id
          text: t.text
          screen_name: t.screen_name
          full_name: t.full_name
        )
      )
    )

timelineView = null

window.app =
  initialize: (initialTweets) ->
    timelineView = new TimelineView
      el: $('#timeline-view')

    tweets.add(data: tweet) for tweet in initialTweets

# for debug
window.getNewTweets = ->
  timelineView.getNewTweets()
