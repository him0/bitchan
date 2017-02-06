// Description:
//   ネタ拾う

"use strict";

module.exports = (robot) => {
  robot.hear(/レムリア/i, (res) => {
    res.send("＿人人人人人人人人＿\n＞　経済圏の中心　＜\n￣Y^Y^Y^Y^Y^Y^Y￣");
  });

  robot.hear(/Gox/i, (res) => {
    res.send("✝グランドゼロ✝");
  });

  robot.hear(/Counterparty/i, (res) => {
    res.send("ぱりーぴーぽー");
  });

  robot.hear(/(すし|寿司)/i, (res) => {
    res.send("🍣");
  });

  robot.hear(/[おろ]うかな/i, (res) => {
    let message =  "よ～く考えよぉ～♪ お金は大事だよぉ～♪\n";
    message += "https://www.youtube.com/watch?v=40ysN8KPY-Y";
    res.send(message);
  });
};
