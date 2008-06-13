#!/usr/bin/env ruby

$: << 'lib'
require 'model'

def main
  map = Map.new
end


if File.basename($0) == File.basename(__FILE__)
  main()
end