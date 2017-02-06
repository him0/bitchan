FROM node
MAINTAINER him0

RUN mkdir /myapp
WORKDIR /myapp
ADD . /myapp
RUN npm install

ENV HUBOT_NAME bitchan
ENV HUBOT_OWNER him0
ENV HUBOT_DESCRIPTION かわいいビットちゃんです。

EXPOSE  80
CMD [ "bin/hubot", "--adapter", "slack" ]
