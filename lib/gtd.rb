require '/home/vd/projects/geek-productivity/gtd/task.rb'

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
