#!/usr/bin/env ruby
require 'js_base'

req 'iosb/test_case_entry'

BANNER =<<-EOS
Build, run, test iOS applications from the command line
EOS

class IOSBuild

  def initialize
    @xcodebuild_list = nil
    @scheme = nil
    @verbose = false
  end

  def run(args=ARGV)

    success = false

    oper = parse_args(args)

    saved_directory = Dir.pwd

    begin
      directory = @options[:directory]
      Dir.chdir(directory) if directory
      if @options[:clean]
        success = run_cmd("xcodebuild clean")
      end

      cmd = nil
      case oper
      when :test
        success = do_test
      when :clean
        cmd = "xcodebuild clean"
      when :build
        cmd = "xcodebuild -sdk iphonesimulator7.0 -scheme \"#{scheme}\""
      end
      success = run_cmd(cmd) if cmd
    ensure
      Dir.chdir(saved_directory)
    end

    exit (success ? 0 : 1)

  end


  private


  def do_test
    cmd = "xcodebuild test -scheme \"#{scheme}\""
    if @options[:destination]
      cmd << " -destination \"#{@options[:destination]}\""
    end
    info("Running command '#{cmd}':")

    output,success = scall(cmd,false)

    if success && !@verbose
      info "...all tests passed"
    else
      puts "Test output:\n#{output}\n"
    end
    success
  end


  def run_cmd(cmd)
    output,success = scall(cmd,false)
    info("Running command '#{cmd}':")
    info(output)
    info("\n")

    if !success
      puts "\n....Problem executing '#{cmd}':\n\n#{output}\n"
    end
    success
  end

  def info(msg)
    if @verbose
      puts msg
    end
  end

  def scheme
    if !@scheme

      schemes = []

      list = xcodebuild_list
      i = list.index('Schemes:')
      if i
        i += 1
        while i < list.size && !list[i].end_with?(':')
          schemes << list[i]
          i += 1
        end
      end

      die "No schemes found" if schemes.empty?

      # If user specified scheme on command line, see if it exists
      preferred_scheme = @options[:scheme]
      if preferred_scheme
        if !schemes.include?(preferred_scheme)
          die "No such scheme '#{preferred_scheme} found; candidates are:\n#{schemes}"
        end
        @scheme = preferred_scheme
      else
        @scheme = schemes[0]
        info("Multiple schemes found: #{schemes}; choosing #{@scheme}") if schemes.size > 1
      end

    end
    @scheme
  end

  def parse_args(argv)

    p = Trollop::Parser.new do
      banner BANNER
      opt :clean,"clean"
      opt :build,"build"
      opt :test,"test (default)"
      opt :verbose,"verbose"
      opt :directory,"directory to start in",:type => :string
      opt :scheme,"scheme",:type => :string
      opt :destination,"destination",:type => :string
    end

    @options = Trollop::with_standard_exception_handling p do
      p.parse argv
    end

    die "extraneous arguments" if !argv.empty?

    oper = mutually_exclusive(@options,[:test,:build])

    @verbose = @options[:verbose]

    oper
  end



  def xcodebuild_list
    if !@xcodebuild_list
      output,success = scall('xcodebuild -list',false)
      if !success
        die("Could not find an XCode project")
      end
      @xcodebuild_list = output.lines.map do |x|
        x.chomp.lstrip
      end
    end
    @xcodebuild_list
  end

  # Verify that at most one of a mutually-exclusive set of options was
  # specified on the command line
  #
  # options: returned by trollop
  # mutually_exclusive_list: list of symbols, e.g., :clean
  # returns the option chosen, of the first in the list if none were
  #
  def mutually_exclusive(options,mutually_exclusive_list)
    chosen_option = nil
    mutually_exclusive_list.each do |opt|
      if options[opt]
        die "options #{mutually_exclusive_list} are mutually exclusive" if chosen_option
        chosen_option = opt
      end
    end
    if !chosen_option
      chosen_option = mutually_exclusive_list[0]
    end
    chosen_option
  end

end

if __FILE__ == $0
  IOSBuild.new.run
end
