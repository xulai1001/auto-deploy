#!/bin/bash
# use rvm to install from ruby.taobao.org
sed -i -E 's!https?://cache.ruby-lang.org/pub/ruby!https://ruby.taobao.org/mirrors/ruby!' $rvm_path/config/db

rvm install 2.2
rvm use 2.2

sudo gem sources --remove https://ruby.taobao.org/
sudo gem sources --add https://ruby.taobao.org/ --remove http://rubygems.org/
gem sources -l
sudo gem install require_all
sudo gem install term-ansicolor

