class TopicSupplier
  news_site_url: "http://hnapp.com/rss?q=score%3E1%20"

  constructor: () ->
    _feed = require "feed-read"
    _pickup_size = 3

    select_topics = (articles, size) ->
      articles = articles.slice(0,size * 3) # トップ size * 3 件に絞る
      selected_topics = []
      topics = []

      # ランダムで size 個を重複なくランダムで選び出す
      while selected_topics.length < size
        topic = articles[Math.floor(Math.random() * articles.length)] # ランダム
        if selected_topics.indexOf(topic) == -1
          selected_topics.push(topic)
          title = topic["title"]
          title = title.replace(/^.+;s /, "").replace(/^.+; /, "") # フィルタ
          topics.push({
            title: title
            title_link: topic["link"]
          })
          console.log "'" +  title + "' is selected."
       return topics

    @random_topics = (keywords, say) ->
      url =  "http://hnapp.com/rss?q="
      url += keywords.join('%20%7C%20') + "%20score%3E1"
      _feed(
        url,
        (err, articles) ->
          throw err if (err)
          topics = select_topics(articles, _pickup_size)
          say topics
      )

module.exports = (robot) ->
  # ts = new TopicSupplier
  # robot.respond /(ニュース|news|話題|topic|)(.*)/i, (msg) ->
  #   keywords = [
  #     'Bitcoin',
  #     'Ethereum',
  #     'NEM'
  #   ]
  #
  #   message =  "話題のニュースですよ！"
  #   message += "(keywords: " + keywords.join(', ') + ")"
  #
  #   topics = ts.random_topics(keywords, (topics) ->
  #     console.log topics
  #
  #     robot.emit 'slack.attachment',
  #       message: msg.message
  #       text: message
  #       content: topics
  #   )
