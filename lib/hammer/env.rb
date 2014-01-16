require 'hamster/hash'
require 'hammer/hamster_ext/hash'

module Hammer

  class ENV < Hamster::Hash
    def add_ns(name)
      put_in([:namespaces, name],
             Hamster.hash(aliases: Hamster.hash, symbols: Hamster.hash))
    end

    def current_ns(ns=nil)
      if ns
        self.put(:current_ns, ns)
      else
        self[:current_ns]
      end
    end

    def merge_symbols(symbols, ns_name=nil)
      update_in(:namespaces, ns_name || current_ns, :symbols) {|syms| syms.merge(symbols)}
    end

    def symbols_for_ns(ns_name=nil)
      get_in(:namespaces, ns_name || current_ns, :symbols)
    end

    def quoted
      self.put(:quoted?, true)
    end

    def quoted?
      self[:quoted?]
    end

    def self.global_env
      @global_env ||= ENV.new.add_ns("user").current_ns("user")
    end

    def self.replace_global_env!(env)
      @global_env = env
    end
  end

end
