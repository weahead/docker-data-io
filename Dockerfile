FROM docker:1.12.3

LABEL maintainer "We ahead <docker@weahead.se>"

COPY root /

ENTRYPOINT ["/docker-entrypoint.sh"]
