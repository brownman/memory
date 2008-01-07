
module System
  LINUX_PAGE_SIZE = 1024
  
  class << self
    def memory
      result = {}
      if `vmstat 2> /dev/null`.empty?
        # OS X
        output = `vm_stat`.split("\n")
        result['page size'] = output.shift[/page size of (\d+) bytes/, 1].to_i
        output.each do |line|
          line =~ /([\w\s]+)"{0,1}:\s*(\d+)/
          key, value = $1, $2
  
          key = case key
            when /Pages (.*)/
              $1 + " memory"
            when "pageouts"
              "pages paged out"
            else
              key
          end          
          result[key.downcase] = value.to_i
        end      
      else
        # Linux
        result['page size'] = LINUX_PAGE_SIZE
        output = `vmstat -s -S K`.split("\n")
        page_size = 1
        output.each do |line|
          line =~ /(\d+)\s*(\w+)/
          key, value = $1, $2
          key.gsub!(/^K /, '')
          result[key] = value.to_i
        end      
      end
      normalize_pages(result)
    end
    
    private 
    
    def normalize_pages(hash)
      hash.each do |key, value|
        if key =~ /memory/
          hash[key] = value * hash['page size']
        end
      end
      hash
    end
    
  end
end

module Process
  class << self
    def memory
      a = `ps -o vsz,rss -p #{Process.pid}`.split(/\s+/)[-2..-1].map{|el| el.to_i}
      {:virtual => a.first - a.last, :total => a.first, :real => a.last, }
    end
  end
end
     