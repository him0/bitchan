# Description:
#   ネタ拾う
#

module.exports = (robot) ->
  robot.hear /レムリア/i, (msg) ->
    msg.send "＿人人人人人人人人＿\n＞　経済圏の中心　＜\n￣Y^Y^Y^Y^Y^Y^Y￣"

  robot.hear /Gox/i, (msg) ->
    msg.send "✝グランドゼロ✝"

  robot.hear /fusan/i, (msg) ->
    randomNumber = Math.floor(Math.random() * 10  % 2)
    if randomNumber == 0
      msg.send "にゃんこ🐱"
    else
      msg.send "おちゃわん🍚"
