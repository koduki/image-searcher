FROM koduki/jupyter-ruby

ADD Gemfile .
RUN gem install rubygems-update --source http://rubygems.org/ && update_rubygems
RUN bundle install