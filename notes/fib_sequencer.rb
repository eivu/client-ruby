# frozen_string_literal: true

class FibSequencer
  # storing the max number of iterations for quick short circuit
  MAX_ITERATIONS = 33

  # if this were to be put in production, and one might consider replacing
  # the cache with a true data store like a database. i could have used sqlite
  # as a proof of concept but i wanted to stay in the timebox
  @@cache = {
    1 => 1,
    2 => 1
  }

  def self.call(n)
    # any number larger than MAX_ITERATIONS (33) will
    # generate a number larger than 4_000_000
    # if suplied short circuit and raise an exception
    if n > MAX_ITERATIONS
      raise(ArgumentError, 'can not generate a number larger than 4_000_000')
    elsif n <= 1
      n
    else
      @@cache[n - 1] ||= self.call( n - 1 )
      @@cache[n - 2] ||= self.call( n - 2 )
      @@cache[n - 1] + @@cache[n - 2]
    end
  end
end
