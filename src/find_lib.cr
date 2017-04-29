module FindLib
  def self.find(name : String)
    res = {% if flag?(:darwin) %}
      files("lib#{name}.#{PLATFORM_SUFFIX}")
    {% elsif flag?(:windows) %}
      files("#{name}??.#{PLATFORM_SUFFIX}")
    {% elsif flag?(:linux) || flag?(:openbsd) || flag?(:freebsd) %}
      files("lib#{name}.#{PLATFORM_SUFFIX}.??")
    {% else %}
      files("lib#{name}.#{PLATFORM_SUFFIX}.??")
    {% end %}
  end

  def self.find(names : Array(String))
    res = [] of String
    names.each do |name|
      find(name).each { |n| res << n }
    end
    res
  end

  SEARCH_PATHS = begin
    x = [] of String
    x << "/usr/local/lib"
    x << "/opt/local/lib"
    x << "/usr/lib"

    {% if flag?(:x86_64) %}
      x << "/usr/local/lib64"
      x << "/opt/local/lib64"
      x << "/usr/lib64"
    {% elsif flag?(:i686) %}
      x << "/usr/lib/i386-linux-gnu"
    {% end %}

    {% if flag?(:windows) %}
      (ENV["PATH"]? || "").split(";").each do |path|
        x << path unless path.blank?
      end
    {% else %}
      (ENV["LIBRARY_PATH"]? || "").split(":").each do |path|
        x << path unless path.blank?
      end
      (ENV["LD_LIBRARY_PATH"]? || "").split(":").each do |path|
        x << path unless path.blank?
      end
    {% end %}

    x
  end

  PLATFORM_SUFFIX = begin
    {% if flag?(:darwin) %}
      "dylib"
    {% elsif flag?(:windows) %}
      "dll"
    {% elsif flag?(:linux) || flag?(:openbsd) || flag?(:freebsd) %}
      "so"
    {% else %}
      "so"
    {% end %}
  end

  private def self.files(name)
    res = [] of String
    Dir.glob(SEARCH_PATHS.map { |path| File.expand_path(File.join(path, name)) }).each do |path|
      res << path
    end
    res
  end
end
