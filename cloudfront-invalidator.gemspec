Gem::Specification.new do |s|
  s.name              = 'cloudfront-invalidator'
  s.version           = '0.1.2'
  s.platform          = Gem::Platform::RUBY
  s.author            = 'Reid M Lynch'
  s.email             = 'reid.lynch@gmail.com'
  s.homepage          = 'http://github.com/reidiculous/cloudfront-invalidator'
  s.summary           = 'Simple gem to invalidate a list of keys belonging to a Cloudfront distribution'
  s.rubyforge_project = s.name

  s.add_dependency('ruby-hmac')
  s.files             = ['lib/cloudfront-invalidator.rb', 'README.md', 'bin/cloudfront-invalidator']
  s.require_path      = 'lib'
  
  s.bindir = "bin"
  s.executables = ["cloudfront-invalidator"]
  s.default_executable = "cloudfront-invalidator"
end