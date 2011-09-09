# > "a.b.c".to_hash("Some value")
# => {"a"=>{"b"=>{"c"=>"Some value"}}}

class String
  def to_hash(val=nil)
    keys = self.split('.')
    Hash.new.tap do |hsh|
      while keys.present? do
        k = keys.shift
        hsh[k.to_s] = keys.blank? ? val : Hash.new
        hsh = hsh[k.to_s]
      end
    end
  end
end