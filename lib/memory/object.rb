
include ObjectSpace

MEMORY_PROFILE_BAD_SIZE_METHOD = {FileTest => true, File => true, File::Stat => true}

class Object
  def memory_profile_size_of_object(seen={})
    return 0 if seen.has_key? object_id
    seen[object_id] = true
    count = 1
    if kind_of? Hash
      each_pair do |key,value|
        count += key.memory_profile_size_of_object(seen)
        count += value.memory_profile_size_of_object(seen)
      end
    elsif kind_of? Array
      count += size
      each do |element|
        count += element.memory_profile_size_of_object(seen)
      end
    end

    count += instance_variables.size
    instance_variables.each do |var|
      count += instance_variable_get(var.to_sym).memory_profile_size_of_object(seen)
    end

    count
  end

  def memory_profile_inspect(seen={},level=0)
    return object_id.to_s if seen.has_key? object_id
    seen[object_id] = true
    result = ' '*level
    if kind_of? Hash
      result += "{\n" + ' '*level
      each_pair do |key,value|
        result += key.memory_profile_inspect(seen,level+1) + "=>\n"
        result += value.memory_profile_inspect(seen,level+2) + ",\n" + ' '*level
      end
      result += "}\n" + ' '*level
    elsif kind_of? Array
      result += "[\n" + ' '*level
      each do |element|
        result += element.memory_profile_inspect(seen,level+1) + ",\n" + ' '*level
      end
      result += "]\n" + ' '*level
    elsif kind_of? String
      result += self
    elsif kind_of? Numeric
      result += self.to_s
    elsif kind_of? Class
      result += to_s
    else
      result += "---"+self.class.to_s + "---\n" + ' '*level
    end


    instance_variables.each do |var|
      result += var + "=" + instance_variable_get(var.to_sym).memory_profile_inspect(seen,level+1) + "\n" + ' '*level
    end

    result
  end

end
