#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint auth0_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name         = 'auth0_flutter'
  s.version      = '1.14.0'
  s.summary      = 'Auth0 SDK for Flutter'
  s.description  = 'Auth0 SDK for Flutter Android and iOS apps.'
  s.homepage     = 'https://auth0.com'
  s.license      = { :file => '../LICENSE' }
  s.author       = { 'Auth0' => 'support@auth0.com' }
  s.source       = { :path => '.' }
  s.source_files = 'Classes/**/*'

  s.ios.deployment_target = '14.0'
  s.ios.dependency 'Flutter'

  s.osx.deployment_target = '11.0'
  s.osx.dependency 'FlutterMacOS'

  s.dependency 'Auth0', '2.10.0'
  s.dependency 'JWTDecode', '3.2.0'
  s.dependency 'SimpleKeychain', '1.2.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version       = ['5.7', '5.8', '5.9']
end
