module Ls       
  def self.find(root, options = {})
    files = []    
    root  = root.to_s
    return files unless File.directory?(root) && File.readable?(root)

    Dir.foreach(root) do |name|
      next if name =~ %r|\A\.\.?|

      path = File.join(root, name)
      type = File.stat(path).ftype rescue nil
      if type != "directory"
        next if options["type"] && options["type"] != type
        next if options["name"] && name !~ (Regexp.new(options["name"].to_s) rescue nil)
      end

      files << path 
    end
    files
  end

  ROOT = if true
    find("/")
  else 
    require "win32ole"
    drives = []
    fs = ::WIN32OLE.new("Scripting.FileSystemObject")
    fs.Drives.each { |drive| drives << drive.Path + "\\" }
    drives
  end
end
