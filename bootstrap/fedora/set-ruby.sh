#!/bin/bash
# use rvm to install from ruby.taobao.org
gem sources --add https://ruby.taobao.org/ --remove http://rubygems.org/
gem sources -l
gem install require_all term-ansicolor

# just also put python init here.
sudo pip install --upgrade pip

