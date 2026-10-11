p require('model/car')
p require('model/shop')
p [$shop_loads, Shop.hooks]
p require('model/tag')
p $tag_loads
require_relative 'model/tag'
p require('model/wheel.rb')
p Wheel::SIZE
p require('model/wheel')
p require('model/car.rb')
