FROM ruby:2.6.3

RUN apt-get update && apt-get install -y rubocop vim

WORKDIR /workspace/clean-up-gmail

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install
