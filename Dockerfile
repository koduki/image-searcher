FROM koduki/jupyter-ruby

ADD Gemfile .
RUN bundle install