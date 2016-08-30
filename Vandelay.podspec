#
# Be sure to run `pod lib lint Vandelay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Vandelay'
  s.version          = '0.2.1'
  s.summary          = 'Vandelay is an importer/exporter for iOS.'

  s.description      = <<-DESC
Vandelay is an importer / exporter for iOS, that can be used to import and 
export data in various ways.

Vandelay supports exporting and importing strings, serialized JSON and iOS
encoded NSData (for more complex objects, image data etc.).

Vandelay versions <1.0.0 will have breaking changes between minor versions.
This means that e.g. 0.3 will not be compatible with 0.2.

                       DESC

  s.homepage         = 'https://github.com/danielsaidi/vandelay'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Saidi' => 'daniel.saidi@gmail.com' }
  s.source           = { :git => 'https://github.com/danielsaidi/vandelay.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/danielsaidi'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Vandelay/Classes/**/*.{swift}'
  
  # s.resource_bundles = {
  #   'Vandelay' => ['Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
