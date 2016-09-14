FROM docker:1.12.1

MAINTAINER We ahead <docker@weahead.se>

RUN apk --no-cache add mysql

COPY root /

ENTRYPOINT ["sh", "-c"]
