require_relative 'node'

class HashMap
  attr_reader :buckets

  INITIAL_SIZE = 16
  LOAD_FACTOR = 0.75

  def initialize
    @capacity = INITIAL_SIZE
    @buckets = Array.new(@capacity)
    @size = 0
  end

  def hash(key)
    hash_code = 0
    prime_number = 31

    key.each_char { |char| hash_code = prime_number * hash_code + char.ord }

    hash_code % @capacity
  end

  def set(key, value)
    index = hash(key)
    raise IndexError if index.negative? || index >= @buckets.length

    if @buckets[index].nil?
      @size += 1
      return @buckets[index] = Node.new(key, value)
    end

    current_node = @buckets[index]
    previous_node = nil

    until current_node.nil?
      return current_node.value = value if current_node.key == key

      previous_node = current_node
      current_node = current_node.next_node
    end

    current_node = Node.new(key, value)
    previous_node.next_node = current_node
    @size += 1
    check_load_factor
  end

  def get(key)
    index = hash(key)
    raise IndexError if index.negative? || index >= @buckets.length

    return nil if @buckets[index].nil?

    current_node = @buckets[index]

    until current_node.nil?
      return current_node.value if current_node.key == key

      current_node = current_node.next_node
    end
    nil
  end

  def has?(key)
    index = hash(key)
    raise IndexError if index.negative? || index >= @buckets.length

    current_node = @buckets[index]

    until current_node.nil?
      return true if current_node.key == key

      current_node = current_node.next_node
    end
    false
  end

  def remove(key)
    index = hash(key)
    raise IndexError if index.negative? || index >= @buckets.length

    return nil if @buckets[index].nil?

    current_node = @buckets[index]
    previous_node = nil

    until current_node.nil?
      if current_node.key == key
        if previous_node.nil?
          @buckets[index] = current_node.next_node
        else
          previous_node.next_node = current_node.next_node
        end
        return current_node.value
      end

      previous_node = current_node
      current_node = current_node.next_node
    end
  end

  def length
    @size
  end

  def clear
    @buckets = Array.new(INITIAL_SIZE)
    @size = 0
  end

  def keys
    arr = []

    @buckets.each do |item|
      next if item.nil?

      until item.nil?
        arr << item.key
        item = item.next_node
      end
    end
    arr
  end

  def values
    arr = []

    @buckets.each do |item|
      next if item.nil?

      until item.nil?
        arr << item.value
        item = item.next_node
      end
    end
    arr
  end

  def entries
    arr = []

    @buckets.each do |item|
      next if item.nil?

      until item.nil?
        arr << [item.key, item.value]
        item = item.next_node
      end
    end
    arr
  end

  private

  def check_load_factor
    return unless @size > @capacity * LOAD_FACTOR

    grow
  end

  def grow
    @capacity *= 2
    new_arr = entries
    @buckets = Array.new(@capacity)
    new_arr.each { |arr| set(arr[0], arr[1]) }
  end
end
