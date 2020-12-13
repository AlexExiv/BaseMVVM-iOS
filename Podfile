source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

def shared_pods
  pod 'Alamofire', '~> 4.7'
  pod 'RxSwift',    '~> 5.1'
  pod 'RxCocoa',    '~> 5.1'
  pod 'RxRelay',    '~> 5.1'
end

target 'BaseMVVM' do
    shared_pods
end

target 'BaseMVVMTests' do
    shared_pods
    
    pod 'RxBlocking', '~> 5.1'
    pod 'RxTest', '~> 5.1'
end

target 'Examples' do
    shared_pods
end
