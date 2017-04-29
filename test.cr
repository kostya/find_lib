require "c/dlfcn"
require "./src/find_lib"

def libicu_files
  {% if flag?(:darwin) %}
    FindLib.find("icucore")
  {% elsif flag?(:windows) %}
    FindLib.find(["icuuc", "icuin"])
  {% else %}
    FindLib.find(["icui18n", "icutu"])
  {% end %}
end

TESTFUNC = "u_init"

def suffixes(path)
  res = [""]

  match = path.match(/(\d\d)\.#{FindLib::PLATFORM_SUFFIX}/) || path.match(/#{FindLib::PLATFORM_SUFFIX}\.(\d\d)/)
  
  if match
    version = match[1]
    res << "_#{version}"
    res << "_#{version[0]}_#{version[1]}"
    res << "_#{version.split('.')[0]}"
  end

  res
end

def detect_suffix(path)
  handle = LibC.dlopen(path, LibC::RTLD_LAZY)
  return if handle.null?
  suffixes(path).each do |suffix|
    return suffix unless LibC.dlsym(handle, "#{TESTFUNC}#{suffix}").null?
  end
  nil
ensure
  LibC.dlclose(handle)
end

puts "files - #{libicu_files.inspect}"

libicu_files.each do |path|
  suffix = detect_suffix(path)
  if suffix
    puts "suffix - #{suffix.inspect}"
    exit 0
  end
end

exit 1
