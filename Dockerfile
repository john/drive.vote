FROM ruby:2.5.1-alpine3.7

RUN apk add --update \
  build-base \
  postgresql-dev \
  bash \
  nodejs \
  tzdata \
  && rm -rf /var/cache/apk/*

RUN gem install bundler

# First copy the bundle files and install gems to aid caching of this layer
WORKDIR /dtv
COPY Gemfile* /dtv/
RUN bundle install

WORKDIR /dtv
COPY . /dtv

EXPOSE 3000