Gem::Specification.new do |s|
  s.name         = 'grafter'
  s.version      = '0.0.1'
  s.platform     = Gem::Platform::RUBY
  s.summary      = 'chroot manager for the modern era'
  s.description  = 'chroot manager for the modern era'
  s.author       = 'Jeffrey Peckham'
  s.homepage      = 'https://github.com/ophymx/grafter'
  s.license       = 'MIT'
  s.email         = 'abic@ophymx.com'
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")

  s.files        = %x(git ls-files -- lib/*).split("\n")

  s.add_dependency 'thor', '~> 0.18.1'


  s.executables << 'grafter'
end
