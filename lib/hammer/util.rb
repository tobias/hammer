module Hammer
  module Util
    class << self
      def put_in(hash, path, value)
        key, *keys = path
        hash.put(key, 
                 if keys.length > 0
                   put_in(hash[key], keys, value)
                 else
                   value
                 end)
      end
    end
  end
end
