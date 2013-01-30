require "rbconfig"

module FsUtil
  def self.ls(path, options = {})
    roots = options[:root] ? Array(options[:root]) : DEFAULT_ROOT_DIRECTORY
    return roots if path.empty?

    # Make sure path starts with one of the roots, checking the longest one first.
    root = roots.sort_by { |i| -i.size }.find { |i| path.start_with?(i) }    
    return roots unless root and !path.include?("..") and File.directory?(path) and File.readable?(path)    

    find(path, options)
  end

  def self.basename(path)
    return unless path
    # On Windows, treat volume+root as the basename
    path =~ %r|\A\w:\\\z| ? path : File.basename(path)
  end

  def self.find(path, options)
    files = []
    
    Dir.foreach(path) do |name|
      next if name =~ %r|\A\.\.?|
      
      file = File.join(path, name)
      type = File.stat(path).ftype rescue nil
      if type != "directory"
        next if options[:type] && options[:type] != type
        next if options[:name] && name !~ (Regexp.new(options[:name].to_s) rescue nil)
      end
      
      files << file
    end
    files
  end    
  
  #class scope!
  #private :find

  DEFAULT_ROOT_DIRECTORY =
    if RbConfig::CONFIG["host_os"] !~ /mswin|mingw/i
      find("/", :type => "directory")
    else
      require "win32ole"
      drives = []
      fs = ::WIN32OLE.new("Scripting.FileSystemObject")
      fs.Drives.each { |drive| drives << drive.Path + "\\" }
      drives
    end
end
