  class Task
    attr_accessor :orig_string, :start, :orig_attributes_str, :attributes, :desc, :origin

    TAGGED_VALUE_REGEX = /(\w+)\:(\w+)\s+/

    def self.parse(from_string)
      t = Task.new
      t.orig_string = from_string + ' ' # add space to parse include statements without description
      return nil unless t.orig_string =~
        /^(?: \s*\*?\s*)                  # allow leading * with white space to both sides
        ((?: DO|[Tt][Oo][Dd][Oo]|DONE|CANDO|CANCEL|INCLUDE):?\s+)  # 1:TODO with optional colon
        (#{TAGGED_VALUE_REGEX}+)?         # tagged values 2:, 3:, 4:
        (.*)                              # 5:title
        /x
      t.start = $1.upcase.strip
      t.orig_attributes_str = $2
      t.desc = $+.strip

      t.attributes = []
      t.attributes = $2.scan(TAGGED_VALUE_REGEX) if $2

      t
    end

    def inner_html
      attr_str = attributes.map{|key, value| "#{key}:#{value} "}.join
      puts "desc:#{desc}END"
      desc_in_html = RDiscount.new(desc).to_html
      puts "desc_in_html:#{desc_in_html}END"
      html = "<span style='font-weight:bold'>#{start}</span>#{attr_str}#{desc_in_html}"
      html = "<del>#{html}</del>" if done?
      html
    end

    def wrap_div(inner)
      "<div class='todo'>#{inner}</div>\n"
    end

    def to_html
      wrap_div(inner_html)
    end

    def done?
      start =~ /DONE|CANCEL/
    end

    def include_statement?
      start =~ /INCLUDE/
    end

    def [](key)
      hit = attributes.detect {|k, value| k.to_s == key.to_s}
      hit ? hit[1] : nil
    end

    def project
      self[:project]
    end

    def context
      self[:context]
    end
  end

class GTD

    def self.inject_todo(orig)
      res = []
      orig.each_line do |line|
        task = Task.parse(line) # try every line as a task decription
        if task.nil?
          res << line
#~        elsif task.include_statement?
#~          recursive = task[:recursive] == 'true' ? ["/#{name}"] : nil
#~          list = TaskList.from_example(task, recursive)
#~          res << list.to_html
        else
          res << task.to_html
        end
      end
      res.join
    end

end
