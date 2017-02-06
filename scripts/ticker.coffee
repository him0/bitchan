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
    _ticker = {}
    # JPY / USD
    _usd_jpy = 0

    # Exchange
    _ticker["polo"] = {
      "BTC": {}, "XEM": {}, "ETH": {}, "XCP": {}, "ETC": {},
      "LSK": {}, "NXT": {}, "ZEC": {}, "SJCX": {}, "XMR": {}, "XRP": {},
    }

    _ticker["zaif"] = {
      "BTC": {}, "XEM": {}, "MONA": {}, "XCP": {}, "SJCX": {},
    }

    @update = () ->
      @update_jpy()
      @update_polo()
      @update_zaif()

      _ticker["polo"]["BTC"]["JPY"] = _ticker["polo"]["BTC"]["USD"] * _usd_jpy

      _ticker["polo"]["XEM"]["JPY"] =
        _ticker["polo"]["XEM"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]
      _ticker["polo"]["ETH"]["JPY"] =
        _ticker["polo"]["ETH"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]
      _ticker["polo"]["XCP"]["JPY"] =
        _ticker["polo"]["XCP"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]

      _ticker["polo"]["ETC"]["JPY"] =
        _ticker["polo"]["ETC"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]
      _ticker["polo"]["LSK"]["JPY"] =
        _ticker["polo"]["LSK"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]
      _ticker["polo"]["NXT"]["JPY"] =
        _ticker["polo"]["NXT"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]
      _ticker["polo"]["ZEC"]["JPY"] =
        _ticker["polo"]["ZEC"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]
      _ticker["polo"]["SJCX"]["JPY"] =
        _ticker["polo"]["SJCX"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]
      _ticker["polo"]["XMR"]["JPY"] =
        _ticker["polo"]["XMR"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]
      _ticker["polo"]["XRP"]["JPY"] =
        _ticker["polo"]["XRP"]["BTC"] * _ticker["polo"]["BTC"]["JPY"]

    @update_jpy = () ->
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
        _ticker["polo"]["BTC"]["USD"] =
          parseFloat(polo_ticker["USDT_BTC"]["last"])

        _ticker["polo"]["XEM"]["BTC"] =
          parseFloat(polo_ticker["BTC_XEM"]["last"])
        _ticker["polo"]["ETH"]["BTC"] =
          parseFloat(polo_ticker["BTC_ETH"]["last"])
        _ticker["polo"]["XCP"]["BTC"] =
          parseFloat(polo_ticker["BTC_XCP"]["last"])

        _ticker["polo"]["ETC"]["BTC"] =
          parseFloat(polo_ticker["BTC_ETC"]["last"])
        _ticker["polo"]["LSK"]["BTC"] =
          parseFloat(polo_ticker["BTC_LSK"]["last"])
        _ticker["polo"]["NXT"]["BTC"] =
          parseFloat(polo_ticker["BTC_NXT"]["last"])
        _ticker["polo"]["ZEC"]["BTC"] =
          parseFloat(polo_ticker["BTC_ZEC"]["last"])
        _ticker["polo"]["SJCX"]["BTC"] =
          parseFloat(polo_ticker["BTC_SJCX"]["last"])
        _ticker["polo"]["XMR"]["BTC"] =
          parseFloat(polo_ticker["BTC_XMR"]["last"])
        _ticker["polo"]["XRP"]["BTC"] =
          parseFloat(polo_ticker["BTC_XRP"]["last"])

    @update_zaif = () ->
      _zaif_items = [
        "btc_jpy", "mona_btc", "mona_jpy", "xem_btc", "xem_jpy",
        "xcp_jpy", "xcp_btc", "sjcx_jpy", "sjcx_btc"
      ]
      for i, item of _zaif_items
        @update_zaif_item(item)

    @update_zaif_item = (item) ->
      options =
        url: @zaif_ticker_url + item
        timeout: 5000
      _request options, (error, response, body) ->
        zaif_ticker = JSON.parse(body)
        _price = parseFloat(zaif_ticker["last_price"])
        switch item
          when "btc_jpy"  then _ticker["zaif"]["BTC"]["JPY"]  = _price
          when "mona_btc" then _ticker["zaif"]["MONA"]["BTC"] = _price
          when "mona_jpy" then _ticker["zaif"]["MONA"]["JPY"] = _price
          when "xem_btc"  then _ticker["zaif"]["XEM"]["BTC"]  = _price
          when "xem_jpy"  then _ticker["zaif"]["XEM"]["JPY"]  = _price
          when "xcp_jpy"  then _ticker["zaif"]["XCP"]["JPY"]  = _price
          when "xcp_btc"  then _ticker["zaif"]["XCP"]["BTC"]  = _price
          when "sjcx_jpy" then _ticker["zaif"]["SJCX"]["JPY"] = _price
          when "sjcx_btc" then _ticker["zaif"]["SJCX"]["JPY"] = _price

    @make_header_message = () ->
      _sprintf("%8s %15s %15s","", "Poloniex", "Zaif")

    @line_format = (polo, zaif) ->
      line = "%8s: "
      line += if polo then "%15.8f " else "               "
      line += if zaif then "%15.8f " else "               "
      line

    @make_jpy_message = () ->
      _sprintf(@line_format(true, false), "USD/JPY ", _usd_jpy)

    @make_btc_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/USD ",
        _ticker["polo"]["BTC"]["USD"]
      )
      message += "\n"
      message += _sprintf(
        @line_format(true, true), "BTC/JPY ",
        _ticker["polo"]["BTC"]["JPY"], _ticker["zaif"]["BTC"]["JPY"]
      )

    @make_xem_message = () ->
      message =  _sprintf(
        @line_format(true, true), "XEM/BTC ",
        _ticker["polo"]["XEM"]["BTC"], _ticker["zaif"]["XEM"]["BTC"]
      )
      message += "\n"
      message += _sprintf(
        @line_format(true, true), "XEM/JPY ",
        _ticker["polo"]["XEM"]["JPY"], _ticker["zaif"]["XEM"]["JPY"]
      )

    @make_eth_message = () ->
      message =  _sprintf(
        @line_format(true, false), "ETH/BTC ",
        _ticker["polo"]["ETH"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "ETH/JPY ",
        _ticker["polo"]["ETH"]["JPY"]
      )

    @make_mona_message = () ->
      message =  _sprintf(
        @line_format(false, true), "MONA/BTC",
        _ticker["zaif"]["MONA"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(false, true), "MONA/JPY",
        _ticker["zaif"]["MONA"]["JPY"]
      )

    @make_xcp_message = () ->
      message =  _sprintf(
        @line_format(true, false), "XCP/BTC ",
        _ticker["polo"]["XCP"]["BTC"], _ticker["zaif"]["XCP"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "XCP/JPY ",
        _ticker["polo"]["XCP"]["JPY"], _ticker["zaif"]["XCP"]["JPY"]
      )

    @make_etc_message = () ->
      message =  _sprintf(
        @line_format(true, false), "ETC/BTC ",
        _ticker["polo"]["ETC"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "ETC/JPY ",
        _ticker["polo"]["ETC"]["JPY"]
      )

    @make_lsk_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/LSK ",
        _ticker["polo"]["LSK"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/LSK ",
        _ticker["polo"]["LSK"]["JPY"]
      )

    @make_zec_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/ZEC ",
        _ticker["polo"]["ZEC"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/ZEC ",
        _ticker["polo"]["ZEC"]["JPY"]
      )

    @make_nxt_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/NXT ",
        _ticker["polo"]["NXT"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/NTX ",
        _ticker["polo"]["NXT"]["JPY"]
      )

    @make_sjcx_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/SJCX",
        _ticker["polo"]["SJCX"]["BTC"], _ticker["zaif"]["SJCX"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/SJCX",
        _ticker["polo"]["SJCX"]["JPY"], _ticker["zaif"]["SJCX"]["JPY"]
      )

    @make_xmr_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/XMR ",
        _ticker["polo"]["XMR"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/XMR ",
        _ticker["polo"]["XMR"]["JPY"]
      )

    @make_xrp_message = () ->
      message =  _sprintf(
        @line_format(true, false), "BTC/XMR ",
        _ticker["polo"]["XRP"]["BTC"]
      )
      message += "\n"
      message +=  _sprintf(
        @line_format(true, false), "JPY/XRP ",
        _ticker["polo"]["XRP"]["JPY"]
      )

    @make_all_message = () ->
      message =  @make_jpy_message()    + "\n"
      message += @make_header_message() + "\n"
      message += @make_btc_message()    + "\n"
      message += @make_xem_message()    + "\n"
      message += @make_eth_message()    + "\n"
      message += @make_mona_message()   + "\n"
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

      switch target
        when 'all'
          _sprintf(@make_massage_format(true), @make_all_message())
        when 'yen', 'jyen', 'jpy'
          _sprintf(@make_massage_format(false), "日本円", @make_jpy_message())
        when 'bitcoin', 'btc', 'xbt'
          _sprintf(@make_massage_format(false), "Bitcoin", @make_btc_message())
        when 'nem', 'xem'
          _sprintf(@make_massage_format(false), "NEM/XEM", @make_xem_message())
        when 'ethereum', 'eth', 'ether'
          _sprintf(@make_massage_format(false), "ETH", @make_eth_message())
        when 'mona'
          _sprintf(@make_massage_format(false), "MONA", @make_mona_message())
        when 'xcp'
          _sprintf(@make_massage_format(false), "XCP", @make_xcp_message())
        when 'etc'
          _sprintf(@make_massage_format(false), "ETC", @make_etc_message())
        when 'lisk', 'lsk'
          _sprintf(@make_massage_format(false), "LISK", @make_lsk_message())
        when 'zec', 'zcash'
          _sprintf(@make_massage_format(false), "ZEC", @make_zec_message())
        when 'nxt'
          _sprintf(@make_massage_format(false), "NXT", @make_nxt_message())
        when 'sjcx'
          _sprintf(@make_massage_format(false), "SJCX", @make_sjcx_message())
        when 'xmr', 'monero'
          _sprintf(@make_massage_format(false), "XMR", @make_xmr_message())
        when 'xrp', 'ripple'
          _sprintf(@make_massage_format(false), "XRP", @make_xrp_message())
        when 'pepe', 'pepechash'
          "＿人人人人人人人人人人＿\n" + "＞　家が買えるぐらい　＜\n" + "￣Y^Y^Y^Y^Y^Y^Y^Y^Y￣"
        else
          "JPY / BTC / XEM / ETH / MONA / XCP / XCP / ETC / LSK / ZEC / NXT / SJCX / XMR / XRP が対応しています。"

cronJob = require('cron').CronJob

module.exports = (robot) ->
  ticker = new Ticker()

  new cronJob('*/15 * * * * *', () ->
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
