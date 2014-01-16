module Hammer
  module HamsterExt
    module Hash
      def update_in(head, *tail, &block)
        self.put(head, 
                 if tail.length > 0
                   (self[head] || Hamster.hash).update_in(*tail, &block)
                 else
                   block.call(self[head])
                 end)
      end

      def put_in(path, value)
        update_in(*path) {|_| value }
      end

      def get_in(head, *tail)
        if tail.length > 0
          if h = self[head]
            h.get_in(*tail)
          else
            nil
          end
        else
          self[head]
        end
      end
    end
  end
end


class Hamster::Hash
  include Hammer::HamsterExt::Hash
end
