FROM docker:1.12.3

MAINTAINER We ahead <docker@weahead.se>

COPY root /

ENTRYPOINT ["sh", "-c"]
