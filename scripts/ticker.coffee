# Description:
#   Bitcoin ticker
#
# Commands:
#   bitchan ticker - show last price of some Crypto Currencies
#   xxxいくら - show last price of some Crypto Currencies

class Ticker
  global_ticker_url: "http://www.gaitameonline.com/rateaj/getrate"
  polo_ticker_url: "https://poloniex.com/public?command=returnTicker"
  zaif_ticker_url: "http://api.zaif.jp/api/1/last_price/"

  constructor: () ->
    _request = require 'request'
    _sprintf = require('sprintf-js').sprintf
    _moment = require("moment");

    # ALL
    # JPY
    _usd_jpy = 0
    # BTC
    _polo_btc_usd = 0
    _polo_btc_jpy = _zaif_btc_jpy = 0
    # XEM
    _polo_xem_btc = _zaif_xem_btc = 0
    _polo_xem_jpy = _zaif_xem_jpy = 0
    # ETH
    _polo_eth_btc = 0
    _polo_eth_jpy = 0
    # MONA
    _zaif_mona_btc = 0
    _zaif_mona_jpy = 0
    # XCP
    _polo_xcp_btc = 0
    _polo_xcp_jpy = 0

    # OPTIONAL
    # ETC
    _polo_etc_btc = 0
    _polo_etc_jpy = 0
    # LSK
    _polo_lsk_btc = 0
    _polo_lsk_jpy = 0
    # NXT
    _polo_nxt_btc = 0
    _polo_nxt_jpy = 0
    # SJCX
    _polo_sjcx_btc = _zaif_sjcx_btc = 0
    _polo_sjcx_jpy = _zaif_sjcx_jpy = 0

    @update = () ->
      @update_global()
      @update_polo()
      for i, item of ["btc_jpy", "mona_btc", "mona_jpy", "xem_btc", "xem_jpy"]
        @update_zaif_item(item)

      _moment = require("moment");

      _polo_btc_jpy = _usd_jpy * _polo_btc_usd

      _polo_xem_jpy = _polo_xem_btc * _polo_btc_jpy
      _polo_eth_jpy = _polo_eth_btc * _polo_btc_jpy
      _polo_xcp_jpy = _polo_xcp_btc * _polo_btc_jpy

      _polo_etc_jpy = _polo_etc_btc * _polo_btc_jpy
      _polo_lsk_jpy = _polo_lsk_btc * _polo_btc_jpy
      _polo_nxt_jpy = _polo_nxt_btc * _polo_btc_jpy
      _polo_sjcx_jpy = _polo_sjcx_btc * _polo_btc_jpy

    @update_global = () ->
      options =
        url: @global_ticker_url
        timeout: 2000

      _request options, (error, response, body) ->
        global_ticker = JSON.parse(body)
        for pair in global_ticker["quotes"]
          if pair["currencyPairCode"] is "USDJPY"
            _usd_jpy = (parseFloat(pair["bid"]) + parseFloat(pair["ask"])) * 0.5

    @update_polo = () ->
      options =
        url: @polo_ticker_url
        timeout: 2000

      _request options, (error, response, body) ->
        polo_ticker = JSON.parse(body)
        _polo_btc_usd = parseFloat(polo_ticker["USDT_BTC"]["last"])
        _polo_xem_btc = parseFloat(polo_ticker["BTC_XEM"]["last"])
        _polo_eth_btc = parseFloat(polo_ticker["BTC_ETH"]["last"])
        _polo_xcp_btc = parseFloat(polo_ticker["BTC_XCP"]["last"])

        _polo_etc_btc = parseFloat(polo_ticker["BTC_ETC"]["last"])
        _polo_lsk_btc = parseFloat(polo_ticker["BTC_LSK"]["last"])
        _polo_nxt_btc = parseFloat(polo_ticker["BTC_NXT"]["last"])
        _polo_sjcx_btc = parseFloat(polo_ticker["BTC_SJCX"]["last"])

    @update_zaif_item = (item) ->
      options =
        url: @zaif_ticker_url + item
        timeout: 2000
      _request options, (error, response, body) ->
        zaif_ticker = JSON.parse(body)
        _price = parseFloat(zaif_ticker["last_price"])
        eval("_zaif_" + item + " = parseFloat(_price)")

    @make_header_message = () ->
      _sprintf("%8s %14s %14s","", "Poloniex", "Zaif")


    @line_format = (polo, zaif) ->
      if polo is true and zaif is true
        "%8s: %14.8f %14.8f"
      else if zaif is true
        "%8s:                %14.8f"
      else
        "%8s: %14.8f"

    @make_jpy_message = () ->
      _sprintf(@line_format(false, false), "USD/JPY ", _usd_jpy)

    @make_btc_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/USD ", _polo_btc_usd
      )
      message += "\n"
      message += _sprintf(
        @line_format(true, true), "BTC/JPY ", _polo_btc_jpy, _zaif_btc_jpy
      )

    @make_xem_message = () ->
      message =  _sprintf(
        @line_format(true, true), "BTC/XEM ", _polo_xem_btc, _zaif_xem_btc
      )
      message += "\n"
      message += _sprintf(
        @line_format(true, true), "JPY/XEM ", _polo_xem_jpy, _zaif_xem_jpy
      )

    @make_eth_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/ETH ", _polo_eth_btc
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/ETH ", _polo_eth_jpy
      )

    @make_mona_message = () ->
      message =  _sprintf(
        @line_format(false, true), "BTC/MONA", _zaif_mona_btc
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(false, true), "JPY/MONA", _zaif_mona_jpy
      )

    @make_xcp_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/XCP ", _polo_etc_btc
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/XCP ", _polo_etc_jpy
      )

    @make_etc_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/ETC ", _polo_etc_btc
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/ETC ", _polo_etc_jpy
      )

    @make_lsk_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/LSK ", _polo_lsk_btc
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/LSK ", _polo_lsk_jpy
      )

    @make_nxt_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/NXT ", _polo_nxt_btc
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/NTX ", _polo_nxt_jpy
      )

    @make_sjcx_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/SJCX", _polo_sjcx_btc
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/SJCX", _polo_sjcx_jpy
      )

    @make_all_message = () ->
      message =  @make_jpy_message() + "\n"
      message += @make_header_message() + "\n"
      message += @make_btc_message() + "\n"
      message += @make_xem_message() + "\n"
      message += @make_eth_message() + "\n"
      message += @make_mona_message() + "\n"
      message += @make_xcp_message()

    @make_massage_format  = (all_mode) ->
      message_format =  _moment().format("MM月DD日 HH:mm:ss")
      message_format += " 現在の"

      if all_mode is true
        message_format +=  "価格は、\n"
      else
        message_format +=  " %s の価格は、\n"

      message_format += "```\n"
      message_format += "%s\n"
      message_format += "```\n"
      message_format += "ですよ！"

    @make_massage = (target) ->

      if target is 'all'
        _sprintf(@make_massage_format(true), @make_all_message())
      else if target is 'yen' or target is 'jyen' or target is 'jpy'
        _sprintf(@make_massage_format(false), "日本円", @make_jpy_message())
      else if target is 'bitcoin' or target is 'btc' or target is 'xbt'
        _sprintf(@make_massage_format(false), "Bitcoin", @make_btc_message())
      else if target is 'nem' or target is 'xem'
        _sprintf(@make_massage_format(false), "NEM/XEM", @make_xem_message())
      else if target is 'ethereum' or target is 'eth'
        _sprintf(@make_massage_format(false), "ETH", @make_eth_message())
      else if target is 'mona'
        _sprintf(@make_massage_format(false), "MONA", @make_mona_message())
      else if target is 'xcp'
        _sprintf(@make_massage_format(false), "XCP", @make_xcp_message())
      else if target is 'etc'
        _sprintf(@make_massage_format(false), "ETC", @make_etc_message())
      else if target is 'lisk' or target is 'lsk'
        _sprintf(@make_massage_format(false), "LISK", @make_lsk_message())
      else if target is 'nxt'
        _sprintf(@make_massage_format(false), "NXT", @make_nxt_message())
      else if target is 'sjcx'
        _sprintf(@make_massage_format(false), "SJCX", @make_sjcx_message())
      else
        "JPY / BTC / XEM / ETH / MONA / XCP / XCP / ETC / LSK / NXT / SJCX が対応しています。"

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
    target = msg.match[1].replace(/bitchan/g, '')
    target = target.replace(/(^\s+)|(\s+$)/g, '') # trim spaces
    target = target.toLowerCase()
    console.log "send ticker message target :" + target
    msg.send ticker.make_massage target
