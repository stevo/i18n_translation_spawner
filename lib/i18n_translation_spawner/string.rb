# > "a.b.c".to_hash("Some value")
# => {"a"=>{"b"=>{"c"=>"Some value"}}}

class String
  def to_hash(val=nil)
    keys = split('.')
    Hash.new.tap do |hsh|
      while k = keys.shift do
        hsh[k] = keys.empty? ? val : Hash.new
        hsh = hsh[k]
      end
    end
  end
end
