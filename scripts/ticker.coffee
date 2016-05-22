# Description:
#   Bitcoin ticker
#
# Commands:
#   hubot ticker - show last price of some Crypto Currencies

class Ticker
  global_ticker_url: "http://www.gaitameonline.com/rateaj/getrate"
  polo_ticker_url: "https://poloniex.com/public?command=returnTicker"

  constructor: () ->
    _request = require 'request'
    _sprintf = require('sprintf-js').sprintf
    _usd_jpy = 0 #
    _btc_usd = 0 #
    _btc_jpy = 0 #
    _eth_btc = 0 #
    _eth_jpy = 0 #
    _xem_btc = 0 #
    _xem_jpy = 0 #

    @update = () ->
      @update_global()
      @update_polo()
      _btc_jpy = _usd_jpy * _btc_usd
      _eth_jpy = _btc_jpy * _eth_btc
      _xem_jpy = _xem_btc * _btc_jpy

    @update_global = () ->
      options =
        url: @global_ticker_url
        timeout: 2000

      _request options, (error, response, body) ->
        global_ticker = JSON.parse(body)
        for pair in global_ticker["quotes"]
          if pair["currencyPairCode"] == "USDJPY"
            _usd_jpy = parseFloat(pair["open"])

    @update_polo = () ->
      options =
        url: @polo_ticker_url
        timeout: 2000

      _request options, (error, response, body) ->
        polo_ticker = JSON.parse(body)
        _btc_usd = parseFloat(polo_ticker["USDT_BTC"]["last"])
        _eth_btc = parseFloat(polo_ticker["BTC_ETH"]["last"])
        _xem_btc = parseFloat(polo_ticker["BTC_XEM"]["last"])

    @update_jpy = () ->

    @send_message = (msg) ->
      console.log "send ticker message"
      msg.send _sprintf "USD/JPY: %14.8f", _usd_jpy
      msg.send _sprintf "BTC/USD: %14.8f", _btc_usd
      msg.send _sprintf "BTC/JPY: %14.8f", _btc_jpy
      msg.send _sprintf "ETH/BTC: %14.8f", _eth_btc
      msg.send _sprintf "ETH/JPY: %14.8f", _eth_jpy
      msg.send _sprintf "XEM/BTC: %14.8f", _xem_btc
      msg.send _sprintf "XEM/JPY: %14.8f", _xem_jpy

cronJob = require('cron').CronJob

module.exports = (robot) ->
  ticker = new Ticker()

  new cronJob('*/5 * * * * *', () ->
    ticker.update(robot)
  ).start()

  robot.respond /ticker/i, (msg) ->
    ticker.send_message(msg)
