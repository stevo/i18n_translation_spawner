=begin
class A
  include LambdaAccessor
  lambda_accessor :test

  def default_test_handler(*args)
     puts args.shift
  end
end

b = A.new
b.test('goof')
b.test_handler = lambda {|*args| "---- #{args[1]} ----"}
=end

module LambdaAccessor
  extend ActiveSupport::Concern
  module ClassMethods
    def lambda_accessor(*args)
      args.map(&:to_s).each do |name|
        attr_accessor "#{name}_handler"

        define_method(name){|*args|
          if (handler = self.send("#{name}_handler")).respond_to?(:call)
            handler.call(*[self, args].flatten)
          else
            self.send("default_#{name}_handler", *args)
          end
        }
      end
    end
  end
end