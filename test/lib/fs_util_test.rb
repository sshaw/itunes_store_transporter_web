require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class FsUtilTest < Minitest::Test
  context "#ls" do
    setup do
      @tmpdir = Dir.mktmpdir
      @root = %w[A B].map do |f|
	path = File.join(@tmpdir, f)
	Dir.mkdir(path)
	path
      end

      stub(FsUtil).root_directory { @root }
    end

    teardown do
      FileUtils.rm_rf(@tmpdir)
    end

    context "when no path is given" do
      should "list files in the default root directory" do
	assert_equal @root, FsUtil.ls("")
	assert_equal @root, FsUtil.ls(nil)
      end
    end

    context "when the path is outside of the root directory" do
      should "list files in the default root directory" do
	assert_equal @root, FsUtil.ls("/")
	assert_equal @root, FsUtil.ls("../")
      end
    end

    context "when the path is inside the root directory" do
      should "list files under the given path" do
	files = create_files(@root.last)
	assert_equal files, FsUtil.ls(@root.last)
      end
    end

    context "with a single root directory option" do
      should "list files under the given path" do
	dir1 = File.join(@root.first, "a1")

	dir2 = File.join(dir1, "a2")
	files = create_files(dir2)

	assert_equal [dir2], FsUtil.ls(dir1, :root => @root.first)
	assert_equal files, FsUtil.ls(dir2, :root => @root.first)
      end
    end

    context "with a root directory option that contains an array of directories" do
      setup do
	root1 = File.join(@root.first, "a1")
	@files1 = create_files(root1)

	root2 = File.join(@root.first, "a2")
	@files2 = create_files(root2)

	@roots = [ root1, root2 ]
      end

      should "list files under the given path" do
	assert_equal @files1, FsUtil.ls(@roots.first, :root => @roots)
	assert_equal @files2, FsUtil.ls(@roots.last, :root => @roots)
      end

      context "when the path is outside of the root directories" do
	should "return the root directory options" do
	  assert_equal @roots, FsUtil.ls("/", :root => @roots)
	end
      end
    end

    context "when the :type options set to 'directory'" do
      should "only return directories" do
	create_files(@tmpdir)
	stub(FsUtil).root_directory { [@tmpdir] }
	assert_equal @root, FsUtil.ls(@tmpdir, :type => "directory")
      end
    end

    context "when on Windows" do
      should "default to using the drive letters as the root directories" do
      end
    end
  end

  context "#basename" do
    should "return the file's basename" do
      assert_equal "c", FsUtil.basename("/a/b/c")
    end

    # On Win File.basename doesn't act like this
    # context "#basename" do
    #   should "not remove the volume when the path only contains a root directory" do
    #     assert_equal "C:\\", FsUtil.basename("C:\\")
    #   end
    # end
  end

  def create_files(root)
    FileUtils.mkdir_p(root)
    3.times.map do |i|
      path = File.join(root, "file#{i}")
      FileUtils.touch(path)
      path
    end
  end
end
