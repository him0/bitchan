// Description:
//   くじ
//
// Commands:
//   bitchan くじ x,x,... - pickup one of them

"use strict";

module.exports = (robot) => {
  robot.respond(/(kuji|くじ|ランダム) (.*)/i, (res) => {
    let seeds = res.match[2].split(",");
    let selected = res.random(seeds).trim();
    msg.send("選ばれたのは、「" + selected + "」でした。");
  });
};
