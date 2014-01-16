require 'parslet'
require 'hamster'

module Hammer

  class Symbol < Struct.new(:symbol)
    def eval(env)
      if env[:quoted?]
        self
      elsif value = env.symbols_for_ns[self.symbol]
        value.eval(env)
      else
        raise "Unknown symbol: #{self.symbol}, current symbols: #{env.symbols_for_ns.inspect}"
      end
    end
  end

  class Value < Struct.new(:value)
    def eval(_)
      value
    end
  end

  class Fn
    attr_reader :env, :arglist, :body

    def initialize(*args)
      @env, @arglist, @body = args
    end

    def eval(env)
      #TODO: this should probably be a deep merge
      scoped_env = self.env.merge_symbols(env.symbols_for_ns)
      lambda do |*args|
        resolved_argslist = self.arglist.eval(env).map(&:symbol).to_a
        args_map = Hamster.hash(resolved_argslist.zip(args.map {|a| Value.new(a)}).to_h)
        self.body.eval(scoped_env.merge_symbols(args_map))
      end
    end
  end

  class QuotedForm < Struct.new(:expression)
    def eval(env)
      expression.eval(env.put(:quoted?, true))
    end
  end

  class BodyForm < Struct.new(:expressions)
    def eval(env=ENV.global_env)
      expressions.map {|x| x.eval(env)}.last
    end
  end

  class IfForm
    attr_reader :cond, :then_clause, :else_clause
    def initialize(*args)
      @env, @cond, @then_clause, @else_clause = args
      #TODO: validate only then and else
    end

    def eval(env)
      if cond.eval(env)
        then_clause.eval(env)
      elsif else_clause
        else_clause.eval(env)
      end
    end
  end

  SPECIAL_FORMS = {"if" => IfForm, "fn" => Fn}
  # special forms:
  # if, let, fn
  # def mutates the global env?

  class ListForm < Struct.new(:contents)
    def eval(env)
      head = contents.head
      if env[:quoted?] || !head
        contents
      elsif head.respond_to?(:symbol) &&
          klass = SPECIAL_FORMS[head.symbol]
        klass.new(env, *contents.tail).eval(env)
      else
        head.eval(env).call(*(contents.tail.map {|x| x.eval(env)}))
      end
    end
  end


end
