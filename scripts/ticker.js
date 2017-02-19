// Description:
//   Bitcoin ticker
//
// Commands:
//   xxxいくら - show last price of some Crypto Currencies

"use strict";

const request = require('request-promise');
const sprintf = require('sprintf-js').sprintf;
const moment = require("moment");
const cronJob = require('cron').CronJob;

class Ticker {
  constructor(updateSequesnce = 20000) {
    this.updateSequesnce = updateSequesnce;

    this["usd_jpy_url"] = "http://www.gaitameonline.com/rateaj/getrate";
    this["polo_ticker_url"] =
    "https://poloniex.com/public?command=returnTicker";
    this["zaif_ticker_url"] = "http://api.zaif.jp/api/1/last_price/";

    this.ticker = {
      USD: { JPY: 0 },

      BTC: { USD: { polo: 0          }, JPY: { polo: 0, zaif: 0 } },

      XEM: { BTC: { polo: 0, zaif: 0 }, JPY: { polo: 0, zaif: 0 } },
      MON: { BTC: {          zaif: 0 }, JPY: {          zaif: 0 } },
      ETH: { BTC: { polo: 0          }, JPY: { polo: 0          } },
      XCP: { BTC: { polo: 0, zaif: 0 }, JPY: { polo: 0, zaif: 0 } },
      ETC: { BTC: { polo: 0          }, JPY: { polo: 0          } },
      LSK: { BTC: { polo: 0          }, JPY: { polo: 0          } },
      NXT: { BTC: { polo: 0          }, JPY: { polo: 0          } },
      ZEC: { BTC: { polo: 0          }, JPY: { polo: 0          } },
      SJC: { BTC: { polo: 0, zaif: 0 }, JPY: { polo: 0, zaif: 0 } },
      XMR: { BTC: { polo: 0          }, JPY: { polo: 0          } },
      XRP: { BTC: { polo: 0          }, JPY: { polo: 0          } },
      PEP: { BTC: {          zaif: 0 }, JPY: {          zaif: 0 } },
    };
    this.updateJpy();
    this.updatePolo();
    this.updateZaif();
  }

  updateJpy() {
    let options = {
      method: "GET",
      url: this["usd_jpy_url"],
      timeout: 3000,
      json: true
    };

    request(options).then((body) => {
      let quotes = body.quotes;

      quotes.forEach((pair) => {
        if(pair["currencyPairCode"] === "USDJPY") {
          let price = (parseFloat(pair["bid"]) + parseFloat(pair["ask"])) * 0.5;
          this.ticker.USD.JPY = price;
          return;
        }
      });
    }).catch((err) => {
      setTimeout(() => { this.updateJpy(); }, 3000);
    });

    setTimeout(() => { this.updateJpy(); }, this.updateSequesnce);
  }

  updatePolo(){
    let charangeTimes = 0;
    let t = this.ticker;

    let options = {
      method: "GET",
      url: this["polo_ticker_url"],
      timeout: 3000,
      json: true
    };

    request(options).then((body) => {
      let poloTicker = body;

      t.BTC.USD.polo = parseFloat(poloTicker["USDT_BTC"]["last"]);

      t.XEM.BTC.polo = parseFloat(poloTicker["BTC_XEM"]["last"]);
      t.ETH.BTC.polo = parseFloat(poloTicker["BTC_ETH"]["last"]);
      t.XCP.BTC.polo = parseFloat(poloTicker["BTC_XCP"]["last"]);

      t.ETC.BTC.polo = parseFloat(poloTicker["BTC_ETC"]["last"]);
      t.LSK.BTC.polo = parseFloat(poloTicker["BTC_LSK"]["last"]);
      t.NXT.BTC.polo = parseFloat(poloTicker["BTC_NXT"]["last"]);
      t.ZEC.BTC.polo = parseFloat(poloTicker["BTC_ZEC"]["last"]);
      t.SJC.BTC.polo = parseFloat(poloTicker["BTC_SJCX"]["last"]);
      t.XMR.BTC.polo = parseFloat(poloTicker["BTC_XMR"]["last"]);
      t.XRP.BTC.polo = parseFloat(poloTicker["BTC_XRP"]["last"]);
    }).catch((err) => {
      setTimeout(() => { this.updatePolo(); }, 3000);
    });

    this.bindLeftValues();
    setTimeout(() => { this.updatePolo(); }, this.updateSequesnce);
  }

  bindLeftValues() {
    let t = this.ticker;
    t.BTC.JPY.polo = t.BTC.USD.polo * t.USD.JPY;

    t.XEM.JPY.polo = t.XEM.BTC.polo * t.BTC.JPY.polo;
    t.ETH.JPY.polo = t.ETH.BTC.polo * t.BTC.JPY.polo;
    t.XCP.JPY.polo = t.XCP.BTC.polo * t.BTC.JPY.polo;

    t.ETC.JPY.polo = t.ETC.BTC.polo * t.BTC.JPY.polo;
    t.LSK.JPY.polo = t.LSK.BTC.polo * t.BTC.JPY.polo;
    t.NXT.JPY.polo = t.NXT.BTC.polo * t.BTC.JPY.polo;
    t.ZEC.JPY.polo = t.ZEC.BTC.polo * t.BTC.JPY.polo;
    t.SJC.JPY.polo = t.SJC.BTC.polo * t.BTC.JPY.polo;
    t.XMR.JPY.polo = t.XMR.BTC.polo * t.BTC.JPY.polo;
    t.XRP.JPY.polo = t.XRP.BTC.polo * t.BTC.JPY.polo;
  }

  updateZaif() {
    let charangeTimes = 0;
    let t = this.ticker;
    let zaifItems = [
      "btc_jpy", "mona_btc", "mona_jpy", "xem_btc", "xem_jpy",
      "xcp_jpy", "xcp_btc", "sjcx_jpy", "sjcx_btc"
    ];

    let options = {
      method: "GET",
      url: "", // need to fill
      timeout: 3000,
      json: true
    };

    zaifItems.forEach((item) => {
      options.url = this["zaif_ticker_url"] + item;
      request(options).then((body) => {
        let price = parseFloat(body["last_price"]);
        switch(item) {
          case("btc_jpy"):  t.BTC.JPY.zaif = price; break;
          case("mona_btc"): t.MON.BTC.zaif = price; break;
          case("mona_jpy"): t.MON.JPY.zaif = price; break;
          case("xem_btc"):  t.XEM.BTC.zaif = price; break;
          case("xem_jpy"):  t.XEM.JPY.zaif = price; break;
          case("xcp_jpy"):  t.XCP.JPY.zaif = price; break;
          case("xcp_btc"):  t.XCP.BTC.zaif = price; break;
          case("sjcx_jpy"): t.SJC.JPY.zaif = price; break;
          case("sjcx_btc"): t.SJC.BTC.zaif = price; break;
        }
      }).catch((err) => { /* どうするか保留 */ });
    });

    setTimeout(() => { this.updateZaif(); }, this.updateSequesnce);
  }

  make_jpy_message() {
    // USD/JPY :    114.28500000

    let message = sprintf("%8s: %9.3f\n", "USD/JPY ", this.ticker.USD.JPY);
    return(message);
  }

  make_btc_message(header = false) {
    //                  Poloniex            Zaif
    // BTC/USD :   1011.50000000
    // BTC/JPY : 115589.16250000 117065.00000000

    let message = "";
    if(header === true) {
      message += sprintf("%8s %15s %15s\n","", "Poloniex", "Zaif");
    }

    message += "BTC/USD: ";
    message += sprintf(" %15.8f", this.ticker.BTC.USD.polo);
    message += "\n";

    message += "BTC/JPY: ";
    message += sprintf(" %15.0f", this.ticker.BTC.JPY.polo);
    message += sprintf(" %15.0f", this.ticker.BTC.JPY.zaif);
    message += "\n";

    return(message);
  }

  make_currency_message(currency, header = false) {
    //                  Poloniex            Zaif
    // XEM/BTC :      0.00000668      0.00000687
    // XEM/JPY :      0.77213561      0.77100000

    let message = "";
    if(header === true) {
      message += sprintf("%8s  %15s %15s\n","", "Poloniex", "Zaif");
    }

    message += currency + "/BTC: ";

    let polo_c_btc = this.ticker[currency].BTC.polo;
    let polo_c_btc_message = "";
    if(polo_c_btc != null) {
      polo_c_btc_message = sprintf(" %15.8f", polo_c_btc);
    }else {
      polo_c_btc_message = sprintf(" %15s", "");
    }
    message += polo_c_btc_message;


    let zaif_c_btc = this.ticker[currency].BTC.zaif;
    let zaif_c_btc_message = "";
    if(zaif_c_btc != null) {
      zaif_c_btc_message = sprintf(" %15.8f", zaif_c_btc);
    }
    message += zaif_c_btc_message;
    message += "\n"

    message += currency + "/JPY: ";
    let polo_c_jpy = this.ticker[currency].JPY.polo;
    let polo_c_jpy_message = "";
    if(polo_c_jpy != null) {
      polo_c_jpy_message = sprintf(" %15.4f", polo_c_jpy);
    }else {
      polo_c_jpy_message = sprintf(" %15s", "");
    }
    message += polo_c_jpy_message;

    let zaif_c_jpy = this.ticker[currency].JPY.zaif;
    let zaif_c_jpy_message = "";
    if(zaif_c_jpy != null) {
      zaif_c_jpy_message = sprintf(" %15.4f", zaif_c_jpy);
    }
    message += zaif_c_jpy_message;
    message += "\n"

    return(message);
  }

  make_all_currency_message() {
    let message = this.make_jpy_message();
    message += '```\n```\n';
    message += this.make_btc_message(true);
    message += this.make_currency_message("XEM", false);
    message += this.make_currency_message("ETH", false);
    message += this.make_currency_message("MON", false);
    message += this.make_currency_message("XCP", false);
    return(message);
  }

  make_pepe_message() {
    let message = "";
    let seed = Math.floor( Math.random() * 3 );
    if(seed == 0) {
      message = "＿人人人人人人人人＿\n" +
                "＞家が買えるぐらい＜\n" +
                "￣Y^Y^Y^Y^Y^Y^Y￣\n";
    }else if(seed == 1) {
      message = "＿人人人人人人人人人人＿\n" +
                "＞速い車が買えるぐらい＜\n" +
                "￣Y^Y^Y^Y^Y^Y^Y^Y^Y￣\n";
    }else {
      message = "＿人人人人人人人人人人＿\n" +
                "＞ヨットが買えるぐらい＜\n" +
                "￣Y^Y^Y^Y^Y^Y^Y^Y^Y￣\n";

    }
    return(message);
  }

  make_massage(target) {
    if([
      'all', 'jpy', 'bitcoin', 'btc', 'nem', 'xem', 'eth', 'mona', 'xcp',
      'etc', 'lsk', 'zec', 'nxt', 'sjcx', 'nmr', 'xrp', 'pepe', 'pepechash'
    ].indexOf(target) === -1) {
      return("JPY / BTC / XEM / ETH / MONA / XCP / XCP / ETC / LSK / ZEC / NXT / SJCX / XMR / XRP が対応しています。\n");
    }

    if(target == "pepe" || target == "pepechash") {
      return(this.make_pepe_message());
    }

    let message =  moment().format("MM月DD日 HH:mm:ss");
    message += " 現在の価格は、\n";
    message += "```";
    message += "\n";

    switch(target) {
      case('all'):
        message += this.make_all_currency_message(); break;
      case('jpy'):
        message += this.make_jpy_message(); break;
      case('bitcoin'):
      case('btc'):
        message += this.make_btc_message(true); break;
      case('nem'):
      case('xem'):
        message += this.make_currency_message("XEM", true); break;
      case('eth'):
        message += this.make_currency_message("ETH", true); break;
      case('mona'):
        message += this.make_currency_message("MON", true); break;
      case('xcp'):
        message += this.make_currency_message("XCP", true); break;
      case('etc'):
        message += this.make_currency_message("ETC", true); break;
      case('lsk'):
        message += this.make_currency_message("LSK", true); break;
      case('zec'):
        message += this.make_currency_message("ZEC", true); break;
      case('nxt'):
        message += this.make_currency_message("NXT", true); break;
      case('sjcx'):
        message += this.make_currency_message("SJC", true); break;
      case('xmr'):
        message += this.make_currency_message("XMR", true); break;
      case('xrp'):
        message += this.make_currency_message("XRP", true); break;
    }
    message += "```";
    message += "\n"
    message += "ですよ！";
    return(message);
  }
}

module.exports = (robot) => {
  let ticker = new Ticker();

  robot.hear(/^(.+)いくら(|\?|？)$/i, (res) => {
    let target = res.match[1].replace(/bitchan/g, '');
    target = target.replace(/(^\s+)|(\s+$)/g, ''); // trim spaces
    target = target.toLowerCase();
    console.log("send ticker message target :" + target);
    res.send(ticker.make_massage(target));
  });
}
