FROM ruby:latest

RUN apt-get update -qq && apt-get install -y locales build-essential libxslt-dev libxml2-dev
ENV LANG C.UTF-8
ENV LANGUAGE en
ENV LC_ALL C.UTF-8

RUN mkdir /validate-website
WORKDIR /validate-website
ADD Gemfile /validate-website/Gemfile
ADD validate-website.gemspec /validate-website/validate-website.gemspec
RUN bundle install
ADD . /validate-website
