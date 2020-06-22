FROM ruby:2.6.4-alpine

ARG PORT=3000

ENV TZ America/Sao_Paulo
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV APP_PATH /app

WORKDIR $APP_PATH 

EXPOSE $PORT

COPY Gemfile .
COPY Gemfile.lock .

ARG BUILD_PACKAGES="build-base g++ gcc make git"
RUN gem install bundler:2.1.4 && \
    bundle config --global --jobs `expr $(grep processor /proc/cpuinfo | wc -l) - 1` && \
    bundle config build.nokogiri --use-system-libraries && \
    apk update && \
    apk add --update --no-cache libxslt-dev ${BUILD_PACKAGES} postgresql-dev less \
    nginx tzdata curl openssl tar && \
    bundle install && \
    apk del ${BUILD_PACKAGES} && \
    rm -r /var/cache/apk/*

COPY . $APP_PATH

CMD ["./scripts/web.sh"]
