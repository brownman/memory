
require "#{File.dirname(__FILE__)}/object"

module Memory
  module Profile

    LOG_FILE = "/tmp/memory_profile.log"
  
    def MemoryProfile::report
      Dir.chdir "/tmp"
      ObjectSpace::garbage_collect
      sleep 10 # Give the GC thread a chance
      all = []
      ObjectSpace.each_object do |obj|
        next if obj.object_id == all.object_id 
          
        all << obj
      end
      
      tally = Hash.new(0)
      max_obj = nil
      max_count = 0
      all.each do |obj|
        count = obj.memory_profile_size_of_object
        if max_count < count
          max_obj = obj
          max_count = count
        end
        
        tally[obj.class]+=count
      end
      
      open( LOG_FILE, 'a') do |outf|
        outf.puts '+'*70
        tally.keys.sort{|a,b| 
          if tally[a] == tally[b]
            a.to_s <=> b.to_s
          else
            -1*(tally[a]<=>tally[b])
          end
        }.each do |klass|
          outf.puts "#{klass}\t#{tally[klass]}"
        end
        
        outf.puts '-'*70
        outf.puts "Max obj was #{max_obj.class} at #{max_count}"
        outf.puts "Maximum object is..."
        outf.puts max_obj.memory_profile_inspect
      end
    end
  
    def MemoryProfile::simple_count
      Dir.chdir "/tmp"
      ObjectSpace::garbage_collect
      sleep 10 # Give the GC thread a chance
  
      tally = Hash.new(0)
      ObjectSpace.each_object do |obj|
        next if obj.object_id == tally.object_id
        tally[obj.class]+=1
      end
      
      open( LOG_FILE, 'a') do |outf|
        outf.puts '='*70
        outf.puts "MemoryProfile report for #{$0}"
        outf.puts `cat /proc/#{Process.pid}/status`
        
        tally.keys.sort{|a,b| 
          if tally[a] == tally[b]
            a.to_s <=> b.to_s
          else
            -1*(tally[a]<=>tally[b])
          end
        }.each do |klass|
          outf.puts "#{klass}\t#{tally[klass]}"
        end
      end
    end
  end
end
  
# if $0 == __FILE__ then
#  File.unlink Memory::Profile::LOG_FILE if File.exist? Memory::Profile::LOG_FILE
#
#  at_exit{ system("cat #{Memory::Profile::LOG_FILE}")}
# end

at_exit do
  Memory::Profile::simple_count
  Memory::Profile::report
end



