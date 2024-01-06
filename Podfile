# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MeloPlace' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MeloPlace
  pod 'SnapKit'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGesture'
  pod 'RxKeyboard'
  pod 'Alamofire'
  pod 'Kingfisher'
  pod 'Swinject'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
  pod 'FirebaseStorage'	
  pod 'FloatingPanel'
  pod 'RxBlocking'




     post_install do |installer|
         installer.generated_projects.each do |project|
               project.targets.each do |target|
                   target.build_configurations.each do |config|
                       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                    end
               end
        end
	installer.pods_project.build_configurations.each do |config|
    		config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "x86_64"
  	end
     end

  target 'MeloPlaceTests' do
    inherit! :search_paths
    # Pods for testing
	pod 'RxTest'

  end

  target 'MeloPlaceUITests' do
    # Pods for testing
  end

end
