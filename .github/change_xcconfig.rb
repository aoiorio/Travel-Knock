require 'yaml'

data = open('./pubspec.yaml', 'r') { |f| YAML.load(f) }
version = data["version"][0..-3]

envs = open("./ios/Flutter/Generated.xcconfig").read()
envs = envs.split("\n").map{|e| e.split("=") }
envs.map! do |e|
  if e[0] == "FLUTTER_BUILD_NAME"
    e[1] = version
  end
  e
end
envs = envs.map{|e| e.join("=") }.join("\n")
open("./ios/Flutter/Generated.xcconfig", "w").write(envs)
