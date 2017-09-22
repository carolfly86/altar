FROM ruby:2.3
RUN gem install bundler
RUN apt-get update
RUN apt-get install -f -y postgresql postgresql-contrib 

ADD . /altar/
WORKDIR /altar/
RUN bundle install
