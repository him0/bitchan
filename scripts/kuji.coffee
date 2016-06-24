# Description:
#   くじ
#

module.exports = (robot) ->
  sample = (array) ->
    size = array.length
    number = Math.floor(Math.random() * size)
    return array[number]

  robot.respond /(kuji|くじ|ランダム) (.*)/i, (msg) ->
    seeds = msg.match[2].split(",")
    selected = (sample seeds).trim()
    msg.send "選ばれたのは、'''" + selected + "'''でした。"
