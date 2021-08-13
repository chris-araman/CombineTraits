Pod::Spec.new do |s|
  s.name     = 'CombineTraits'
  s.version  = '0.1.0'

  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'Combine Publishers with Guarantees'
  s.homepage = 'https://github.com/groue/CombineTraits'
  s.author   = { 'Gwendal Roué' => 'gr@pierlis.com' }
  s.source   = { :git => 'https://github.com/groue/CombineTraits.git', :tag => "v#{s.version}" }

  s.swift_versions = ['5.1', '5.2', '5.3', '5.4']
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'

  s.source_files = 'Sources/**/*.swift'
end
