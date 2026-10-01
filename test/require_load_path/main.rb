p require('model/car')
p require('model/shop')
require_relative 'model/shop'
p [$shop_loads, Shop.hooks]
