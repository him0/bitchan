# Description:
#   Topic Supplier
#

class TopicSupplier
  news_site_url: "http://hnapp.com/rss?q=score%3E1%20"

  constructor: (keywords) ->
    _feed = require "feed-read"
    _pickup_size = 3
    _keywords = keywords
    _topics = []

    select_topics = (articles, size) ->
      articles = articles.slice(0, size * 3) # トップ size * 3 件に絞る
      selected_topics = []
      topics = []

      # ランダムで size 個を重複なくランダムで選び出す
      while selected_topics.length < size
        topic = articles[Math.floor(Math.random() * articles.length)] # ランダム
        if selected_topics.indexOf(topic) == -1
          selected_topics.push(topic)
          title = topic["title"]
          title = title.replace(/^.+;s /, "").replace(/^.+; /, "") # フィルタ
          link = topic["link"]
          topics.push({
            title: title
            title_link: link
          })
      return topics

    @supply = (say) ->
      url =  "http://hnapp.com/rss?q="
      url += _keywords.join('%20%7C%20') + "%20score%3E1"
      _feed(
        url,
        (err, articles) ->
          throw err if (err)
          topics = select_topics articles, _pickup_size
          say topics
      )

module.exports = (robot) ->
  keywords = [
    'Bitcoin',
    'Ethereum',
    'NEM'
  ]
  ts = new TopicSupplier keywords

  robot.respond /(ニュース|news|話題|topic)/, (msg) ->
    ts.supply((topics) ->
      console.log topics
      robot.emit 'slack.attachment',
        message: msg.message
        text: "話題のニュースですよ！"
        content: topics
    )
