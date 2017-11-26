FROM ruby:2.4.0

ADD Gemfile .
RUN gem install rubygems-update --source http://rubygems.org/ && update_rubygems
RUN bundle install