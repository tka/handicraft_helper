Gem::Specification.new do |s|
  s.name        = "handicraft_helper"
  s.version     = "2.0"
  s.date        = "2012-05-14"
  s.authors     = ["Handlino Inc."]
  s.email       = ["dev@handlino.com"]
  s.homepage    = "http://handlino.com"
  s.summary     = "Handicraft Helper"
  s.description = "Handicraft Helper"
  s.files = Dir.glob("{lib}/**/*") + %w(LICENSE README) # 只有列在這裡的檔案會打包到 Gem package 裡面。
end

