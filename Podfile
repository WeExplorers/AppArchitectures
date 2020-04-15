platform :ios, '10.0'
source 'https://cdn.cocoapods.org/'

use_frameworks!

workspace 'AppArchitectures.xcworkspace'

target 'MVC' do
    project 'MVC/MVC.xcodeproj'
end

target 'MVCRxSwift' do
    project 'MVC+RxSwift/MVCRxSwift.xcodeproj'
    pod 'RxSwift'
    pod 'RxCocoa'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.0'
        end
    end
end