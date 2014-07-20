class TestParseError < Exception; end

class TestCaseEntry
  attr_reader :name
  attr_accessor :passed
  def initialize(name)
    @name = name
    @passed = false
    @output = []
    @description = nil
  end

  def add(output_line)
    @output << output_line
  end

  FIRST_LINE_EXPR = /^(.+):([0-9]+): error: (.*):\s*(.*)/
  MAX_LINE_LENGTH = 120
  def to_s
    if !@description
      indent = "  "
      s = ""
      @output.each_with_index do |line,index|
        if index == 0
          # First line is special; fiddle with it if possible
          match = FIRST_LINE_EXPR.match(line)
          if match
            path = match[1]
            line_number = match[2].to_i
            remainder = match[4]

            file = File.basename(path)
            line = "#{file}:#{line_number}: #{remainder}"
          end
          if line.length > MAX_LINE_LENGTH
            line = line[0...MAX_LINE_LENGTH-3] + "..."
          end
        end

        s << indent
        s << line
        s << "\n"
      end
      @description = s
    end
    @description
  end
end

