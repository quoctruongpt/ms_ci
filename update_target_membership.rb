#!/usr/bin/env ruby
require 'xcodeproj'

# Đường dẫn đến xcodeproj (bạn có thể truyền vào thông qua tham số dòng lệnh)
project_path = ARGV[0] || 'Unity-iPhone.xcodeproj'
project = Xcodeproj::Project.open("#{project_path}")

# Tìm file reference của thư mục Data
data_file_ref = project.files.find { |f| f.path == 'Data' }
if data_file_ref.nil?
  puts "Không tìm thấy file reference của 'Data' trong project."
  exit(1)
end

# Tìm target Unity-iPhone và UnityFramework
unity_iphone_target = project.native_targets.find { |t| t.name == 'Unity-iPhone' }
unity_framework_target = project.native_targets.find { |t| t.name == 'UnityFramework' }

if unity_iphone_target.nil? || unity_framework_target.nil?
  puts "Không tìm thấy target 'Unity-iPhone' hoặc 'UnityFramework'."
  exit(1)
end

# Loại bỏ 'Data' khỏi các build phase của Unity-iPhone
unity_iphone_target.build_phases.each do |phase|
  next unless phase.respond_to?(:files)
  original_count = phase.files.count
  phase.files.delete_if { |bf| bf.file_ref == data_file_ref }
  if phase.files.count != original_count
    puts "Đã loại bỏ 'Data' khỏi build phase '#{phase.display_name}' của Unity-iPhone."
  end
end

# Kiểm tra xem Data đã có trong UnityFramework chưa
data_in_framework = unity_framework_target.build_phases.any? do |phase|
  phase.respond_to?(:files) && phase.files.any? { |bf| bf.file_ref == data_file_ref }
end

unless data_in_framework
  # Thêm 'Data' vào Resources build phase của UnityFramework
  resources_phase = unity_framework_target.resources_build_phase
  new_build_file = resources_phase.add_file_reference(data_file_ref, 'Public')
  puts "Đã thêm 'Data' vào build phase Resources của UnityFramework với target membership Public."
else
  puts "'Data' đã thuộc UnityFramework."
end

project.save
puts "Đã cập nhật project.pbxproj thành công!"
