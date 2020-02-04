#
# Be sure to run `pod lib lint USE_CreateCreditCardController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'USE_CreateCreditCardController'
  s.version          = '0.1.3'
  s.summary          = 'USE_CreateCreditCardController is a UIViewController for input credit card.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
USE_CreateCreditCardController is a UIViewController for input credit card.
                       DESC

  s.homepage         = 'http://git.usemobile.com.br/libs-iOS/create-credit-card-controller'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Claudio Madureira' => 'claudio@usemobile.xyz' }
  s.source           = { :git => 'http://git.usemobile.com.br/libs-iOS/create-credit-card-controller.git', :tag => s.version.to_s }
  s.swift_version    = '4.2'
  s.ios.deployment_target = '8.2'

  s.source_files = 'USE_CreateCreditCardController/Classes/**/*'
  
  s.resource_bundles = {
    'USE_CreateCreditCardController' => ['USE_CreateCreditCardController/Classes/**/*.xib']
  }
end
