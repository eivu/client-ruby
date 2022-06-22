# regex: 
# https://regex101.com/r/VydCXH/1\
# https://stackoverflow.com/questions/18053865/regular-expression-for-double-parentheses


# \(\((((?>[^\(\(\)\)]+)|(?R))*)\)\)

# this ((is)) a ((very)) ((useful)) thing


re = /\(\((((?>[^\(\(\)\)]+)|(?R))*)\)\)/ig
str = 'this ((is)) a ((very)) ((useful)) thing'

# Print the match result
str.scan(re) do |match|
  puts match.to_s
end
