class Hash
  def deep_stringify_keys
    inject({}) { |result, (key, value)|
      value = value.deep_stringify_keys if value.is_a?(Hash)
      result[(key.to_s rescue key) || key] = value
      result
    }
  end unless Hash.method_defined?(:deep_stringify_keys)

  def deep_stringify_keys!
    stringify_keys!
    each do |k, v|
      self[k] = self[k].deep_stringify_keys! if self[k].is_a?(Hash)
    end
    self
  end unless Hash.method_defined?(:deep_stringify_keys!)

  def self.convert_hash_to_ordered_hash(object, deep = false)
    # Hash is ordered in Ruby 1.9!
    if RUBY_VERSION >= '1.9'
      return object
    else
      if object.is_a?(Hash)
        ActiveSupport::OrderedHash.new.tap do |map|
          object.each { |k, v| map[k] = deep ? convert_hash_to_ordered_hash(v, deep) : v }
        end
      elsif deep && object.is_a?(Array)
        array = Array.new
        object.each_with_index { |v, i| array[i] = convert_hash_to_ordered_hash(v, deep) }
        return array
      else
        return object
      end
    end
  end

  def to_ordered_hash(deep = false)
    Hash.convert_hash_to_ordered_hash(self, deep)
  end
end