require 'hammer/env'
require 'hamster/hash'
require 'hammer/hamster_ext/hash'

module Hammer

  class BaseForm < Hamster::Hash
    def self.new(meta, content)
      super(content.to_h.merge(meta: meta))
    end

    def method_missing(m, *args, &block)
      if self.has_key?(m)
        self[m]
      else
        super
      end
    end
  end
  
  class Symbol < BaseForm
    def self.new(meta, name)
      super(meta, name: name)
    end

    def name
      self[:name]
    end
    
    def eval(env)
      if env.quoted?
        self
      elsif value = env.symbols_for_ns[self.name]
        value.eval(env)
      else
        raise "Unknown symbol: #{self.name} at #{meta[:line]}:#{meta[:col]}, current symbols: #{env.symbols_for_ns.inspect}"
      end
    end
  end

  class IopCall < Symbol
    def eval(env)
      if env.quoted?
        self
      else
        lambda do |obj, *args|
          obj.__send__(self[:name][1..-1], *(args.map {|a| a.eval(env)}))
        end
      end
    end
  end
  
  class Value < BaseForm
    def self.new(meta, value)
      super(meta, value: value)
    end
    
    def eval(_)
      value
    end
  end

  class Body < BaseForm
    def self.new(expressions)
      super({}, expressions: expressions)
    end
    
    def eval(base_env=nil)
      # grab the global_env on every iteration when this is a
      # top-level body. This doesn't fucking work though, since it
      # requires defs to all be top-level
      expressions.map {|x| x.eval(base_env || ENV.global_env)}.last
    end
  end

  class Fn < BaseForm
    def self.new(*args)
      super({}, env: args[0], arglist: args[1], body: Body.new(args[2..-1]))
    end

    def eval(env)
      #TODO: this should probably be a deep merge
      scoped_env = self.env.merge_symbols(env.symbols_for_ns)
      lambda do |*args|
        resolved_argslist = self.arglist.eval(env).map(&:name).to_a
        args_map = Hamster.hash(resolved_argslist.zip(args.map {|a| Value.new({}, a)}))
        body.eval(scoped_env.merge_symbols(args_map))
      end
    end
  end

  class Def < BaseForm
    def self.new(env, name, value)
      super({}, env: env, name: name, value: value)
    end

    def eval(env)
      # ugh, need to replace the global env?
    end
  end
  
  class Quoted < BaseForm
    def self.new(expression)
      super({}, expression: expression)
    end
    
    def eval(env)
      self[:expression].eval(env.quoted)
    end
  end

  class If < BaseForm
    def self.new(*args)
      super({}, [:env, :cond, :then_clause, :else_clause].zip(args))
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

  class Let < BaseForm
    def self.new(*args)
      super({}, env: args[0], bindings: args[1], body: Body.new(args[2..-1]))
    end

    def eval(env)
      body.eval(env.merge_symbols(Hamster.hash(Hash[*bindings.eval(env)].map {|k,v| [k.name, v]})))
    end
  end
  
  SPECIAL_FORMS = {"if" => If, "fn" => Fn, "let" => Let}

  class List < BaseForm
    def self.new(contents)
      super({}, contents: contents)
    end
    
    def eval(env)
      contents = self[:contents]
      head = contents.head
      if env.quoted? || !head
        contents
      elsif head.respond_to?(:name) &&
          klass = SPECIAL_FORMS[head.name]
        klass.new(env, *contents.tail).eval(env)
      else
        head.eval(env).call(*(contents.tail.map {|x| x.eval(env)}))
      end
    end
  end


end
