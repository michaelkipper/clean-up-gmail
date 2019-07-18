FROM ruby:2.6.3

WORKDIR /workspace/clean-up-gmail

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install
