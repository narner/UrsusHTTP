Pod::Spec.new do |s|
  s.name                    = "Ursus"
  s.version                 = "1.0.0"
  s.summary                 = "An Urbit HTTP client for iOS/macOS."
  s.homepage                = "https://github.com/dclelland/Ursus"
  s.license                 = { :type => 'MIT' }
  s.author                  = { "Daniel Clelland" => "daniel.clelland@gmail.com" }
  s.source                  = { :git => "https://github.com/dclelland/Ursus.git", :tag => "1.0.0" }

  s.ios.deployment_target   = '13.0'
  s.ios.source_files        = 'Ursus/**/*.swift'

  s.osx.deployment_target   = '10.13'
  s.osx.source_files        = 'Ursus/**/*.swift'
end
