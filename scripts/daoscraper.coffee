# Description:
#   Scraping the proposal of The DAO.
#

class ProposalIndex
  proposal_json_url: 'http://vote.daohub.org/proposals.json'

  constructor: () ->
    _proposals_titles = []
    _request = require 'request'

    @meaage_shortener = (message) ->
      return message

    @update = (send_message) ->
      current_proposals_tiles = []
      messages = []

      options =
        url: @proposal_json_url
        timeout: 2000

      _request options, (error, response, body) ->
        proposals_json = JSON.parse(body)
        for p in proposals_json["proposals"]
          if p[8] == false
            console.log p[2]
            current_proposals_tiles.push p[2]

      for message in messages
        send_message @meaage_shortener message

cronJob = require('cron').CronJob

module.exports = (robot) ->
  pi = new ProposalIndex

  robot.respond /proposals/i, (msg) ->
    console.log "proposals"
    pi.update (message) ->
      msg.send message
