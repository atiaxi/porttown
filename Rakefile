#!/usr/bin/env ruby

require 'rake'
require 'rake/runtest'
require 'rake/gempackagetask'
require 'rubygems'

require 'lib/globals'

gem_spec = Gem::Specification.new do |s|
  s.name        = $GEM_NAME
  s.bindir      = "bin"
  s.version     = $PORTTOWN_VERSION.join(".")
  s.author      = "Roger Ostrander"
  s.email       = "atiaxi@gmail.com"
  s.homepage    = "http://llynmir.net/~roger/porttown/"
  s.summary     = "Turn-based strategy of pirates vs. zombies"
  s.description = "Yer favorite tradin' port an' plunderin' spot's been overrun by the undead! Best send them back to Davy Jones' locker, so ye can get back to lootin'!"
  s.has_rdoc    = false
  s.add_dependency('rubygame','>=2.3.0')
  s.executables << 'porttown'
  
  s.files = FileList.new do |fl|
    fl.include("{lib,images,data}/**/*")
    fl.exclude(/git/)
  end
  
  s.require_paths = ["lib"]
  s.test_file = "tests/tests.rb"
  
end

Rake::GemPackageTask.new(gem_spec) do | pkg |
  pkg.need_tar_bz2 = true
  pkg.need_zip = true
  pkg.need_tar = true
end

task :test do
  Rake.run_tests 'tests/tests.rb'
end