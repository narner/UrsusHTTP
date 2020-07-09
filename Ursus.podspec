Pod::Spec.new do |s|
  s.name = "Ursus"
  s.version = "1.2.4"
  s.summary = "An Urbit HTTP/`%eyre` client for iOS/macOS."
  s.homepage = "https://github.com/dclelland/Ursus"
  s.license = { type: 'MIT' }
  s.author = { "Daniel Clelland" => "daniel.clelland@gmail.com" }
  s.source = { git: "https://github.com/dclelland/Ursus.git", tag: "1.2.4" }
  s.swift_versions = ['5.1', '5.2']
  
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  
  s.source_files = 'Ursus/**/*.swift'
  
  s.dependency 'Alamofire', '~> 5.2'
  
  s.subspec 'Atom' do |ss|
    ss.source_files = 'Ursus Atom/**/*.swift'
    ss.dependency 'BigInt', '~> 5.0'
    ss.dependency 'Parity', '~> 2.3'
  end
  
  s.subspec 'EventSource' do |ss|
    ss.source_files = 'Ursus Event Source/**/*.swift'
  end
end
