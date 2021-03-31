source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

def shared_pods
  pod 'Alamofire', '~> 4.7'
  pod 'RxSwift',    '~> 6.1.0'
  pod 'RxCocoa',    '~> 6.1.0'
  pod 'RxRelay',    '~> 6.1.0'
end

target 'BaseMVVM' do
    shared_pods
end

target 'BaseMVVMTests' do
    shared_pods
    
    pod 'RxBlocking', '~> 6.1.0'
    pod 'RxTest', '~> 6.1.0'
end

target 'Examples' do
    shared_pods
end
