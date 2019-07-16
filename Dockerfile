FROM ruby:2.6.3
COPY Gemfile .
RUN bundle install
