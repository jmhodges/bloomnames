import hashlib
 
FILTER_SIZE = 30000

class BloomNames (object):
    """
    A Bloom Filter for tracking 3,000 'names', where 'names' are any
    strings of any length. Can be used to track less than 3,000 names, or more, 
    but going over will increase the false positive rate. This is currently
    tuned for a false positive rate of 1%.
    
    By tuned, that means that the following Bloom Filter parameters 
    are used:
    
    Number of hash functions: 
    k = 7  
    Number of bits in filter array: 
    m = 30,000
    Number of elements added to filter: 
    n = 3,000
    """
    def __init__(self, filter=0L):
        """
        Construct with a zero for an empty filter, or
        pass in a long for an already built filter.
        """
        self.filter = filter
        
    def _hashes(self, name):
        """
        To create seven hash functions we use the sha1 hash of the
        string 'name' and chop that up into 20 bit values and then
        mod down to the length of the Bloom filter, in this case 
        30,000.
        """
        m = hashlib.sha1()
        m.update(name)
        digits = m.hexdigest()
        hashes = [int(digits[i*5:i*5+5], 16) % FILTER_SIZE for i in range(7)]
        return hashes  
    
    def add(self, name):
        """
        Add a key to the filter.
        """
        for pos in self._hashes(name):
            self.filter |= (2 ** pos)
            
    def contains(self, name):
        """
        Determine if a key is a member of the filter.
        """
        retval = True
        for pos in self._hashes(name):
            retval = retval and bool(self.filter & (2 ** pos))
        return retval
    
    __contains__ = contains
                
    def getfilter(self):
        return self.filter
