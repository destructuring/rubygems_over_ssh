Gem::Specification.new do |s|
  s.name        = "rubygems_over_ssh"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Osheroff"]
  s.email       = ["ben@gimbo.net"]
  s.homepage    = ""
  s.summary     = "leverage your pub-key architecture with a private gem host"
  s.description = ""

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency("net-ssh-gateway")
  s.files        = Dir.glob("lib/**/*")
  s.test_files   = Dir.glob("test/**/*")
  s.require_path = 'lib'
end
