BEGIN {
	f = File.new "whitelist.config", "r"
	$whitelist = []
	while (line = f.gets)
		$whitelist.push(line.chomp)
	end
}

module TeachRuby

  # This module contains methods added to all Objects for use with
  # TeachRuby code transformation.
  module ObjectMixin

    # Used to check if a value is of a type which has been blacklisted
    # values consist of: literals, hashes, arrays, method return vals
    def __value_forbidden_check(value)
        if not $whitelist.include? value.class.to_s
           raise TypeError, "TeachRuby: Value " << value.to_s << " has forbidden type " << value.class.to_s
        end
        return value
    end

    alias_method :__v, :__value_forbidden_check

    # Used to intelligently dispatch procedural-style method calls.
    #
    # If called in a context where an implicit method call would succeed,
    # the method call is invoked as:
    # 
    #       self.method(*args, &block)
    #
    # If an implicit Kernel method call is made, the following method 
    # is invoked: 
    #
    #       Kernel.method(*args, &block)
    #
    # If an implicit call would fail, use the first argument of the method
    # call as the callee, removing it from the list of arguments.  That is,
    # if args = [arg0, arg1, arg2, ...], the following method is invoked:
    #
    #       arg0.method(arg1, arg2, ..., &block)
    def __procedural_function_call(method, *args, &block)
      if self.respond_to? method
        __v(self.send(method, *args, &block))
      elsif Kernel.respond_to? method
        __v(Kernel.send(method, *args, &block))
      else
        obj, rest = args[0], args[1..-1]
        if obj.nil?
          # TODO: Better error reporting
          raise ArgumentError, "Oh noes!"
        else
          __v(obj.send(method, *rest, &block))
        end
      end
    end

    alias_method :__p, :__procedural_function_call
  end
end

class Object
  include TeachRuby::ObjectMixin
end