require 'digest/sha1'

# Derived from a python implementation by Joe Gregorio:
# http://bitworking.org/news/380/bloom-filter-resources

# A Bloom Filter for tracking 3,000 'names', where 'names' are any
# strings of any length. Can be used to track less than 3,000 names, or more, 
# but going over will increase the false positive rate. This is currently
# tuned for a false positive rate of 1%.
#  
# By tuned, that means that the following Bloom Filter parameters 
# are used:
#
# Number of hash functions: 
#    k = 7  
# Number of bits in filter array: 
#    m = 30,000
# Number of elements added to filter: 
#    n = 3,000

class BloomNames
  FILTER_SIZE = 30000

  attr_reader :filter

  # Construct with a zero for an empty filter, or
  # pass in a Fixnum for an alreadly built filter
  def initialize(filter=0)
    @filter = filter
  end

  # Add a key to the filter.
  def <<(name)
    hashes(name).each{ |pos| @filter |= 2 ** pos }
    self
  end
  alias :add :<<

  # Determine if a key is a member of the filter.
  def include?(name)
    hashes(name).all?{ |pos| !(@filter & (2 ** pos)).zero? }
  end
  alias :contains :include?

  def inspect
    "#<BloomNames bytes: #{filter.size}>"
  end

  private
  # To create seven hash functions we use the sha1 hash of the
  # string 'name' and chop that up into 20 bit values and then
  # mod down to the length of the Bloom filter, in this case 
  # 30,000.
  def hashes(name)
    digits = Digest::SHA1.hexdigest(name)
    
    (0..6).map do |i| 
      digits[i*5,5].to_i(16) % FILTER_SIZE
    end
  end
end
