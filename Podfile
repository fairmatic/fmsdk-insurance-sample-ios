# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'FairmaticInsuranceSample' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FairmaticInsuranceSample
  
  pod 'FairmaticSDK', :git => 'https://github.com/fairmatic/fairmatic-cocoapods', :tag => '3.1.0'
  pod 'MBProgressHUD', '1.2.0'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
