require 'rake'

Gem::Specification.new do |s|
  s.name        = 'iosb'
  s.version     = '0.0.0'
  s.date        = '2013-12-04'
  s.summary     = "Builds, runs, and tests iOS projects from command line"
  s.description = "more to come"
  s.authors     = ["Jeff Sember"]
  s.email       = 'jpsember@gmail.com'
  s.files = FileList['lib/**/*.rb',
                      'bin/*',
                      '[A-Z]*',
                      'test/**/*',
                      ]
  s.executables << 'iosb'
  s.homepage = 'http://www.cs.ubc.ca/~jpsember'
  s.test_files  = Dir.glob('test/*.rb')
  s.license     = 'MIT'
end
