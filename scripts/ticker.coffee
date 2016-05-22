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
    _jpy_usd = 0 # 日本円 / ドル
    _jpy_btc = 0 # 日本円 / BTC
    _usd_btc = 0 # ドル   / BTC
    _btc_eth = 0 # BTC    / ETH
    _jpy_eth = 0 # 日本円 / ETH

    @update = () ->
      @update_global()
      @update_polo()
      _jpy_btc = _jpy_usd * _usd_btc
      _jpy_eth = _jpy_btc * _btc_eth

    @update_global = () ->
      options =
        url: @global_ticker_url
        timeout: 2000

      _request options, (error, response, body) ->
        global_ticker = JSON.parse(body)
        for pair in global_ticker["quotes"]
          if pair["currencyPairCode"] == "USDJPY"
            _jpy_usd = parseFloat(pair["open"])

    @update_polo = () ->
      options =
        url: @polo_ticker_url
        timeout: 2000

      _request options, (error, response, body) ->
        polo_ticker = JSON.parse(body)
        _usd_btc = parseFloat(polo_ticker["USDT_BTC"]["last"])
        _btc_eth = parseFloat(polo_ticker["BTC_ETH"]["last"])

    @update_jpy = () ->

    @send_message = (msg) ->
      console.log "send ticker message"
      msg.send _sprintf "JPY_USD: %14.8f", _jpy_usd
      msg.send _sprintf "USD_BTC: %14.8f", _usd_btc
      msg.send _sprintf "BTC_ETH: %14.8f", _btc_eth
      msg.send _sprintf "JPY_BTC: %14.8f", _jpy_btc
      msg.send _sprintf "JPY_ETH: %14.8f", _jpy_eth

cronJob = require('cron').CronJob

module.exports = (robot) ->
  ticker = new Ticker()

  new cronJob('*/5 * * * * *', () ->
    ticker.update(robot)
  ).start()

  robot.respond /ticker/i, (msg) ->
    ticker.send_message(msg)
