
module Memory
  module Usage
    # Returns an array of the running process's real and virtual memory usage, in kilobytes.
    def read
      a = `ps -o vsz,rss -p #{Process.pid}`.split(/\s+/)[-2..-1].map{|el| el.to_i}
      [a.first - a.last, a.last]
    end
  end
end

class Process
  def memory_usage
    Memory::Usage.read
  end
end
     