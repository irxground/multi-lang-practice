
# ---- ---- ---- define List ---- ---- ----
List = Struct.new(:item, :next) do
  def fold_right(seed, &block)
    seed = self.next.fold_right seed, &block if self.next
    block.call(self.item, seed)
  end

  def inspect
    self.item.inspect + ". " + (self.next.nil? ? "" : self.next.inspect)
  end
end

# ---- ---- ---- define Monadaa ---- ---- ----

module Monadaa
  REQUIRED_METHOD = [:map, :bind]
  @regist = {}

  module_function
  def [](klass)
    @regist[klass] or raise "#{klass} is not a Monadaa instance."
  end

  def register(klass, &block)
    obj = Object.new
    obj.instance_eval &block
    REQUIRED_METHOD.each do |m|
      raise "Must implement #{m} for #{klass}" unless obj.respond_to? m
    end
    @regist[klass] = obj
  end
end

def flat(xs, ys, &block)
  m = Monadaa[xs.class]
  m.bind xs do |x|
    m.map ys do |y|
      yield x, y
    end
  end
end

# ---- ---- ---- List is Monadaa ---- ---- ----
Monadaa.register List do
  def map(xs, &block)
    xs.fold_right nil do |item, dst|
      List.new (yield item), dst
    end
  end

  def bind(xs, &block)
    xs.fold_right nil do |x, y|
      (yield x).fold_right y, &List.method(:new)
    end
  end
end

# ---- ---- ---- Execute block ---- ---- ----
begin
  one = List.new( 1, List.new( 2, List.new( 3, nil)))
  ten = List.new(10, List.new(20, List.new(30, nil)))
  p flat(one, ten, &:+)
end

