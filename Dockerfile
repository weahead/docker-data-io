FROM docker:latest

LABEL maintainer="We ahead <docker@weahead.se>"

COPY root /

ENTRYPOINT ["/docker-entrypoint.sh"]
