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
    _dao_btc = 0 #
    _dao_eth = 0 #
    _eth_dao = 0 #
    _dao_jpy = 0 #
    _lsk_btc = 0 #
    _lsk_jpy = 0 #

    @update = () ->
      @update_global()
      @update_polo()
      _btc_jpy = _usd_jpy * _btc_usd
      _eth_jpy = _btc_jpy * _eth_btc
      _xem_jpy = _xem_btc * _btc_jpy
      _dao_eth = _dao_btc / _eth_btc
      _eth_dao = _eth_btc / _dao_btc
      _dao_jpy = _dao_btc * _btc_jpy
      _lsk_jpy = _btc_jpy * _lsk_btc

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
        _dao_btc = parseFloat(polo_ticker["BTC_DAO"]["last"])
        _lsk_btc = parseFloat(polo_ticker["BTC_LSK"]["last"])

    @make_jpy_message = () ->
      message =  _sprintf("USD/JPY: %14.8f", _usd_jpy)
      return message

    @make_btc_message = () ->
      message =  _sprintf("BTC/USD: %14.8f", _btc_usd) + " "
      message += _sprintf("BTC/JPY: %14.8f", _btc_jpy)
      return message

    @make_eth_message = () ->
      message =  _sprintf("ETH/BTC: %14.8f", _eth_btc) + " "
      message += _sprintf("ETH/JPY: %14.8f", _eth_jpy)
      return message

    @make_xem_message = () ->
      message =  _sprintf("XEM/BTC: %14.8f", _xem_btc) + " "
      message += _sprintf("XEM/JPY: %14.8f", _xem_jpy)
      return message

    @make_dao_message = () ->
      message =  _sprintf("DAO/BTC: %14.8f", _dao_btc) + " "
      message += _sprintf("DAO/ETH: %14.8f", _dao_eth) + " "
      message += _sprintf("ETH/DAO: %14.8f", _eth_dao) + " "
      message += _sprintf("DAO/JPY: %14.8f", _dao_jpy)
      return message

    @make_lsk_message = () ->
      message =  _sprintf("LSK/BTC: %14.8f", _lsk_btc) + " "
      message += _sprintf("LSK/JPY: %14.8f", _lsk_jpy)
      return message

    @make_all_message = () ->
      message =  ""
      message += @make_jpy_message() + "\n"
      message += @make_btc_message() + "\n"
      message += @make_eth_message() + "\n"
      message += @make_xem_message() + "\n"
      message += @make_dao_message() + "\n"
      message += @make_lsk_message()
      return message

    @make_massage = (target) ->
      message = ""
      if target == 'all'
        message =  '現在の価格は、\n'
        message += @make_all_message(message) + "\n"
        message += "ですよ！"
      else if target == 'yen' or target == 'jyen' or target == 'jpy'
        message =  '現在の日本円の価格は、\n'
        message += @make_jpy_message(message) + "\n"
        message += "ですよ！"
      else if target == 'bitcoin' or target == 'btc' or target == 'xbt'
        message =  '現在の Bitcoin の価格は、\n'
        message += @make_btc_message(message) + "\n"
        message += "ですよ！"
      else if target == 'ethereum' or target == 'eth'
        message =  '現在の Ethereum の価格は、\n'
        message += @make_eth_message(message) + "\n"
        message += "ですよ！"
      else if target == 'nem' or target == 'xem'
        message =  '現在の NEM の価格は、\n'
        message += @make_xem_message(message) + "\n"
        message += "ですよ！"
      else if target == 'dao' or target == 'ザダオ'
        message =  '現在のザダオ (DAO) の価格は、\n'
        message += @make_dao_message(message) + "\n"
        message += "ですよ！"
      else if target == 'lisk' or target == 'lsk'
        message =  '現在の LISK の価格は、\n'
        message += @make_lsk_message(message)
      else
        message =  'ticker all / jpy / btc / eth / xem / dao / lsk のいずれかで呼んでね♥'

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
    msg.send ticker.make_massage target

  robot.hear /^(.+)いくら(|\?|？)$/i, (msg) ->
    target = msg.match[1].replace(/:bitchan /g, '')
    target = target.replace(/(^\s+)|(\s+$)/g, '') # trim spaces
    target = target.toLowerCase()
    console.log "send ticker message target :" + target
    msg.send ticker.make_massage target
