#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint add_to_gallery.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'add_to_gallery'
  s.version          = '1.0.0'
  s.summary          = 'Saves images and videos to gallery and photos.'
  s.description      = <<-DESC
Saves images and videos to gallery and photos.
                       DESC
  s.homepage         = 'https://github.com/flowmobile/add_to_gallery'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flow Mobile' => 'david@flowmobile.app' }
  s.source           = { :path => '.' }
  s.source_files = 'add_to_gallery/Sources/add_to_gallery/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'add_to_gallery_privacy' => ['add_to_gallery/Sources/add_to_gallery/PrivacyInfo.xcprivacy']}
end
