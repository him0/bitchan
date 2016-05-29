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

    @send_jpy_message = (msg) ->
      msg.send _sprintf "USD/JPY: %14.8f", _usd_jpy

    @send_btc_message = (msg) ->
      msg.send _sprintf "BTC/USD: %14.8f", _btc_usd
      msg.send _sprintf "BTC/JPY: %14.8f", _btc_jpy

    @send_eth_message = (msg) ->
      msg.send _sprintf "ETH/BTC: %14.8f", _eth_btc
      msg.send _sprintf "ETH/JPY: %14.8f", _eth_jpy

    @send_xem_message = (msg) ->
      msg.send _sprintf "XEM/BTC: %14.8f", _xem_btc
      msg.send _sprintf "XEM/JPY: %14.8f", _xem_jpy

    @send_all_message = (msg) ->
      @send_jpy_message(msg)
      @send_btc_message(msg)
      @send_eth_message(msg)
      @send_xem_message(msg)

cronJob = require('cron').CronJob

module.exports = (robot) ->
  ticker = new Ticker()

  new cronJob('*/5 * * * * *', () ->
    ticker.update(robot)
  ).start()

  robot.respond /ticker(.*)/i, (msg) ->
    target = msg.match[1].replace(/(^\s+)|(\s+$)/g, '') # trim spaces
    target = target.toLowerCase()
    console.log "send ticker message target :" + target

    if target == '' or target == 'all'
      ticker.send_all_message(msg)
    else if target == 'yen' or target == "jpy"
      ticker.send_jpy_message(msg)
    else if target == 'bitcoin' or target == "btc" or target == "xbt"
      ticker.send_btc_message(msg)
    else if target == 'ethereum' or target == "eth"
      ticker.send_eth_message(msg)
    else if target == 'nem' or target == "xem"
      ticker.send_xem_message(msg)
    else
      ticker.send_all_message(msg)
