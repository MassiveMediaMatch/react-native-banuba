require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = package['name']
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']
  s.summary      = "Banuba SDK"

  s.authors      = package['author']
  s.homepage     = package['homepage']
  s.platform     = :ios, "11.0"
  
  s.source       = { :git => "https://github.com/MassiveMediaMatch/react-native-banuba.git", :tag => "v#{s.version}" }
  s.source_files  = "ios/**/*.{h,m,swift}"

  s.dependency 'React'
  s.dependency 'BanubaARCloudSDK'
  s.dependency 'BanubaVideoEditorSDK'
  s.dependency 'BanubaAudioBrowserSDK'
  s.dependency 'BanubaMusicEditorSDK'
  s.dependency 'BanubaOverlayEditorSDK'
  s.dependency 'BanubaSDKSimple'
  s.dependency 'BanubaSDKServicing'
  s.dependency 'VideoEditor'
  s.dependency 'BanubaUtilities'
  s.dependency 'BanubaLicenseServicingSDK'
  # s.dependency 'BanubaTokenStorageSDK'
  
  s.vendored_frameworks = "BanubaARCloudSDK.xcframework",
                          "BanubaAudioBrowserSDK.xcframework",
                          "BanubaMusicEditorSDK.xcframework",
                          "BanubaOverlayEditorSDK.xcframework",
                          "BanubaVideoEditorSDK.xcframework",
                          "BanubaSDKSimple.xcframework",
                          "BanubaSDKServicing.xcframework",
                          "VideoEditor.xcframework",
                          "BanubaUtilities.xcframework",
                          "BanubaLicenseServicingSDK.xcframework"
                          # "BanubaTokenStorageSDK.xcframework"
end
