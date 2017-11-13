FROM docker:latest

LABEL maintainer="We ahead <docker@weahead.se>"

ENV AWS_CLI_VERSION=1.11.182\
		PYTHONIOENCODING=UTF-8\
		PAGER=cat

RUN apk --no-cache add \
			groff \
			python2 \
			py2-pip \
		&& pip --no-cache-dir install awscli==${AWS_CLI_VERSION}

COPY root /

ENTRYPOINT ["/docker-entrypoint.sh"]
