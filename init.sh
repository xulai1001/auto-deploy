#!/bin/bash
apt-get install ruby2.0 rake 
gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org
gem sources -l
gem install term-ansicolor require_all

