FROM node
MAINTAINER him0

RUN mkdir /myapp
WORKDIR /myapp
ADD . /myapp
RUN npm install
RUN npm install -g forever
RUN touch out.log
RUN touch error.log

ENV HUBOT_NAME bitchan
ENV HUBOT_OWNER him0
ENV HUBOT_DESCRIPTION かわいいビットちゃんです。

EXPOSE  80
CMD [ "bin/hubot" ]
