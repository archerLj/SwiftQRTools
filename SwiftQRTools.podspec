Pod::Spec.new do |spec|

  spec.name         = "SwiftQRTools"
  spec.version      = "0.2"
  spec.summary      = "Scan QR、Generate QR Code and read QR Code info from image."
  spec.description  = <<-DESC
		Scan QR、Generate QR Code and read QR Code info from image.
                   DESC
  spec.homepage     = "https://github.com/archerLj/SwiftQRTools"
  spec.license      = "MIT"
  spec.author             = { "git" => "lj0011977@163.com" }
  spec.platform     = :ios, "10.0"
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/archerLj/SwiftQRTools.git", :tag => "#{spec.version}" }
  spec.source_files  = "SwiftQRTools/SwiftQRTools/*.swift"
  spec.requires_arc = true
  spec.swift_version = "5.0"

end
