random_pickup = (array, num) ->
  pickup_items = []

  while pickup_items.length < num
    r = Math.floor(Math.random() * array.length)
    pickup_item = array[r]

    if pickup_items.indexOf(pickup_item) == -1
      pickup_items.push(pickup_item)

  return pickup_items

module.exports = (robot) ->
  robot.respond /ニュース|news/i, (msg) ->
    feed = require("feed-read")
    keywords = [
      'Bitcoin',
      'Ethereum',
      'NEM'
    ].join('%20%7C%20')
    feed(
      "http://hnapp.com/rss?q=" + keywords + "%20score%3E1",
      (err,articles) ->
        throw err if (err)

        items = random_pickup(articles.slice(0,10), 3)
        message = "ランダムで暗号通貨に関係する話題を投下します！\n"

        news = []
        for item in items
          title = item["title"].replace(/^.+;s /, "").replace(/^.+; /, "")
          news.push({
            title: title
            title_link: item["link"]
          })
          console.log(title)

        robot.emit 'slack.attachment',
          message: msg.message
          text: message
          content: news
    )
