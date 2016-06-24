# Description:
#   ネタ拾う
#

module.exports = (robot) ->
  robot.hear /レムリア/i, (msg) ->
    msg.send "＿人人人人人人人人＿\n＞　経済圏の中心　＜\n￣Y^Y^Y^Y^Y^Y^Y￣"

  robot.hear /Gox/i, (msg) ->
    msg.send "✝グランドゼロ✝"

  robot.hear /^fusan$/i, (msg) ->
    randomNumber = Math.floor(Math.random() * 10  % 2)
    if randomNumber == 0
      msg.send "にゃんこ🐱"
    else
      msg.send "おちゃわん🍚"

  robot.hear /Counterparty/i, (msg) ->
    msg.send "ぱりーぴーぽー"

  robot.hear /(すし|寿司)/i, (msg) ->
    msg.send "🍣"

  robot.hear /[おろ]うかな/i, (msg) ->
    message =  "よ～く考えよぉ～♪ お金は大事だよぉ～♪\n"
    message += "https://www.youtube.com/watch?v=40ysN8KPY-Y"
    msg.send message
