require 'csv'
require 'open-uri'
require 'date'

# There are non-UTF8 characters. This seems to make it so that we can read
# all of the files. I have no idea what this does with characters it can't read.
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

def count_troll_types(filename)
  puts filename
  
  if filename.start_with? 'http'
    # read a whole 90 MB file; this will be SLOW!!!!
    csv_text = open(filename)
  else
    # read the text of the whole file
    csv_text = File.read(filename)
  end
  # now parse the file, assuming it has a header row at the top
  csv = CSV.parse(csv_text, :headers => true)

  # These are the header categories
  # You can get more information about each category if you scroll
  # down to the README.md here:
  # https://github.com/fivethirtyeight/russian-troll-tweets
  '''
  external_author_id
  author
  content
  region
  language
  publish_date
  harvested_date
  following
  followers
  updates
  post_type
  account_type
  new_june_2018
  retweet
  account_category
  '''

  linenum = 0

  # hash from categories to the number of tweets in category
  # keys are categories (string), values are count (integers)
  categories = Hash.new
  # go through each row of the csv file
  csv.each do |row|
    # convert the row to a hash
    # the keys of the hash will be the headers from the csv file
    hash = row.to_hash
    # this is a trick to make sure that this key exists in a hash
    # so that the next line which adds 1 will never fail
    if !categories.include? hash['account_category']
      categories[hash['account_category']] = 0
    end
    # This cannot fail because if the key hadn't existed,
    # then the previous if will have created it
    categories[hash['account_category']] += 1

    # You can use this to stop at 1000 rows
    # break if linenum >= 1000
    linenum += 1
  end

  # now print the key/value pairs
  categories.each do |key, value|
    puts "#{key} appears #{value} times"
  end
end

# This is really really really slow! It reads a 90 MB file
# This may not even finish if you run it on REPL
#count_troll_types('https://github.com/fivethirtyeight/russian-troll-tweets/raw/master/IRAhandle_tweets_1.csv')

if $PROGRAM_NAME == __FILE__
# count_troll_types("IRAhandle_tweets_1.csv")

end

def most_tweet_day(filename)
csv_text = File.read(filename)
csv = CSV.parse(csv_text, headers: true)
categories = {}
csv.each do |row|
  hash = row.to_hash
  # Dates into a hash
  day = hash['publish_date'].split[0]
  # If date is new -> create a new key-value pair
  categories[day] = 0 unless categories.include? day
  # Increment by 1
  categories[day] += 1
end
# 10 days with the most tweets
date = categories.sort_by { |_k, v| v }.reverse
puts
puts "What were the dates of the 10 days that contained the most tweets?"
puts
index = 1
date.each do |key, value|
  puts "#{index}) #{key}: #{value} tweets."
  index += 1
  break if index == 11
end
end

def most_tweet_hour(filename)
csv_text = File.read(filename)
csv = CSV.parse(csv_text, headers: true)
categories = {}
csv.each do |row|
  hash = row.to_hash
  time = hash['publish_date'].split[1].split(':', 0)
  categories[time[0]] = 0 unless categories.include? time[0]
  categories[time[0]] += 1
end
most_time = categories.sort_by { |_k, v| v }.reverse
puts
puts "What hour of the day had the most tweets?"
puts
index = 1
most_time.each do |key, value|
  puts "#{key}: #{value} times."
  index += 1
  break if index == 2
end
end

def most_common_word(filename)
  csv_text = File.read(filename)
  csv = CSV.parse(csv_text, headers: true)
  categories = {}
  common_word_arr = ["the", "be", "to", "of", "and", "a", "in", "that", "have", "i", "it", "for", "not", "on", "with", "he", "as", "you", "do", "at", "this", "but", "his", "by", "from", "they", "we", "say", "her", "she", "or", "will", "an", "my", "one", "all", "would", "there", "their", "what", "so", "up", "out", "with", "about", "who", "get", "which", "go", "when", "me", "make", "can", "like", "time", "no", "just", "him", "know", "take", "person", "into", "year", "your", "good", "some", "could", "them", "see", "other", "than", "then", "now", "look", "only", "come", "its", "over", "think", "also", "back", "after", "use", "two", "hour", "our", "work", "first", "well", "way", "even", "new", "want", "because", "any", "these", "give", "day", "most", "us", "is", "di", "che", "non", "e", "la", "il", "un", "a", "è", "per", "in", "una", "sono", "si", "mi", "le", "con", "i", "ha", "lo", "ho", "da", "ma", "del", "come", "ti", "cosa", "se", "no", "ci", "io", "della", "questo", "al", "qui", "bene", "sei", "hai", "tu", "più", "gli", "solo", "nel", "me", "era", "mio", "tutto", "dei", "alla", "sì", "anche", "te", "c", "questa", "o", "essere", "lei", "l", "quando", "ne", "mia", "fare", "fatto", "perché", "ora", "stato", "tutti", "so", "cosi", "molto", "va", "mai", "quello", "detto", "chi", "suo", "delle", "due", "sua", "lui", "prima", "oh", "dove", "uno", "hanno", "grazie", "nella", "su", "voglio", "niente", "ad", "abbiamo", "ancora", "allora", "sta", " tuo", "sia", "fa", "casa", "siamo", "и", "в", "не", "он", "на", "я", "что", "тот", "быть", "с", "а", "весь", "это", "как", "она", "по", "но", "они", "к", "у", "ты", "из", "мы", "за", "вы", "так", "же", "от", "сказать", "этот", "который", "мочь", "человек", "о", "один", "ещё", "бы", "такой", "только", "себя", "своё", "какой", "когда", "уже", "для", "вот", "кто", "да", "говорить", "год", "dont", "are", "has", "was", "how", "amp", "great", "mr", "if", "being", "wont", "doesnt", "still", "always", "should", "-"] #Thanks, Google!
  csv.each do |row|
    hash = row.to_hash
    #Create an array of words
    if hash['language'] == "English" #Get rid of non-numeric characters in English tweets because there are tweets in other languages
      arr = hash['content'].downcase!.to_s.split(' ')
      arr.each do |word|
        word.to_s.gsub!(/\W/, "")
      end
      content = arr.reject(&:empty?)
    else 
      content = hash['content'].downcase!.to_s.split(' ')
    end
    #Count how many times words appear
    content.each do |word|
      if not common_word_arr.include? word #Exclude all common word in English, Italian and Russian
        unless categories.include? word 
          categories[word] = 0
        end
        categories[word] += 1
      end
    end
  end
  puts
  puts "What is the most common word that occurs across these tweets?"
  puts
  most_word = categories.sort_by { |_k, v| v }.reverse
  index = 1
  most_word.each do |key, value|
    puts "'#{key}': #{value} times."
    index += 1
    break if index == 2
  end
end

def author_most_common_word(filename)
  csv_text = File.read(filename)
  csv = CSV.parse(csv_text, headers: true)
  categories = {}
  common_word_arr = ["the", "be", "to", "of", "and", "a", "in", "that", "have", "i", "it", "for", "not", "on", "with", "he", "as", "you", "do", "at", "this", "but", "his", "by", "from", "they", "we", "say", "her", "she", "or", "will", "an", "my", "one", "all", "would", "there", "their", "what", "so", "up", "out", "with", "about", "who", "get", "which", "go", "when", "me", "make", "can", "like", "time", "no", "just", "him", "know", "take", "person", "into", "year", "your", "good", "some", "could", "them", "see", "other", "than", "then", "now", "look", "only", "come", "its", "over", "think", "also", "back", "after", "use", "two", "hour", "our", "work", "first", "well", "way", "even", "new", "want", "because", "any", "these", "give", "day", "most", "us", "is", "di", "che", "non", "e", "la", "il", "un", "a", "è", "per", "in", "una", "sono", "si", "mi", "le", "con", "i", "ha", "lo", "ho", "da", "ma", "del", "come", "ti", "cosa", "se", "no", "ci", "io", "della", "questo", "al", "qui", "bene", "sei", "hai", "tu", "più", "gli", "solo", "nel", "me", "era", "mio", "tutto", "dei", "alla", "sì", "anche", "te", "c", "questa", "o", "essere", "lei", "l", "quando", "ne", "mia", "fare", "fatto", "perché", "ora", "stato", "tutti", "so", "cosi", "molto", "va", "mai", "quello", "detto", "chi", "suo", "delle", "due", "sua", "lui", "prima", "oh", "dove", "uno", "hanno", "grazie", "nella", "su", "voglio", "niente", "ad", "abbiamo", "ancora", "allora", "sta", " tuo", "sia", "fa", "casa", "siamo", "и", "в", "не", "он", "на", "я", "что", "тот", "быть", "с", "а", "весь", "это", "как", "она", "по", "но", "они", "к", "у", "ты", "из", "мы", "за", "вы", "так", "же", "от", "сказать", "этот", "который", "мочь", "человек", "о", "один", "ещё", "бы", "такой", "только", "себя", "своё", "какой", "когда", "уже", "для", "вот", "кто", "да", "говорить", "год", "dont", "are", "has", "was", "how", "amp", "great", "mr", "if", "being", "wont", "doesnt", "still", "always", "should", "-"] #Thanks, Google!
  csv.each do |row|
    word = {}
    hash = row.to_hash
    if hash['language'] == "English"
      arr = hash['content'].downcase!.to_s.split(' ')
      arr.each do |word|
        word.to_s.gsub!(/\W/, "")
      end
      cont = arr.reject(&:empty?)
    else 
      cont = hash['content'].downcase!.to_s.split(' ')
    end
    cont.each do |x|
      if not common_word_arr.include? x 
        unless word.include? x
          word[x] = 0
        end
        word[x] += 1
      end
    end
    #Sort the hash by values
    
    #Put the most use words of each author in a hash with key is the author and value is the word
    unless categories.include? hash['author']
      categories[hash['author']] = word
      else
        word.each do |key, value|
          unless categories[hash['author']].include? key
          categories[hash['author']][key] = 0
          categories[hash['author']][key] += 1
        else
          #Adding the value to the value of the key
          categories[hash['author']][key] += value
        end
        end
    end
  end
  puts
  puts "What are 10 most common words used by each author?"
  puts
  index = 1
  #Print out the words with their authors and times they were used
    categories.each do |key, value|
    common_word = value.sort_by { |_k, v| v }.reverse.to_a
    index = 1
    puts "10 most common words used by user #{key}:"
    common_word.each do |word|
      puts "#{index}) '#{word[0]}': #{word[1]} times"
      break if index == 10
      index += 1
    end
    puts
  end
end

def most_common_word_each_type(filename)
  csv_text = File.read(filename)
  csv = CSV.parse(csv_text, headers: true)
  categories = {}
  common_word_arr = ["the", "be", "to", "of", "and", "a", "in", "that", "have", "i", "it", "for", "not", "on", "with", "he", "as", "you", "do", "at", "this", "but", "his", "by", "from", "they", "we", "say", "her", "she", "or", "will", "an", "my", "one", "all", "would", "there", "their", "what", "so", "up", "out", "with", "about", "who", "get", "which", "go", "when", "me", "make", "can", "like", "time", "no", "just", "him", "know", "take", "person", "into", "year", "your", "good", "some", "could", "them", "see", "other", "than", "then", "now", "look", "only", "come", "its", "over", "think", "also", "back", "after", "use", "two", "hour", "our", "work", "first", "well", "way", "even", "new", "want", "because", "any", "these", "give", "day", "most", "us", "is", "di", "che", "non", "e", "la", "il", "un", "a", "è", "per", "in", "una", "sono", "si", "mi", "le", "con", "i", "ha", "lo", "ho", "da", "ma", "del", "come", "ti", "cosa", "se", "no", "ci", "io", "della", "questo", "al", "qui", "bene", "sei", "hai", "tu", "più", "gli", "solo", "nel", "me", "era", "mio", "tutto", "dei", "alla", "sì", "anche", "te", "c", "questa", "o", "essere", "lei", "l", "quando", "ne", "mia", "fare", "fatto", "perché", "ora", "stato", "tutti", "so", "cosi", "molto", "va", "mai", "quello", "detto", "chi", "suo", "delle", "due", "sua", "lui", "prima", "oh", "dove", "uno", "hanno", "grazie", "nella", "su", "voglio", "niente", "ad", "abbiamo", "ancora", "allora", "sta", " tuo", "sia", "fa", "casa", "siamo", "и", "в", "не", "он", "на", "я", "что", "тот", "быть", "с", "а", "весь", "это", "как", "она", "по", "но", "они", "к", "у", "ты", "из", "мы", "за", "вы", "так", "же", "от", "сказать", "этот", "который", "мочь", "человек", "о", "один", "ещё", "бы", "такой", "только", "себя", "своё", "какой", "когда", "уже", "для", "вот", "кто", "да", "говорить", "год", "dont", "are", "has", "was", "how", "amp", "great", "mr", "if", "being", "wont", "doesnt", "still", "always", "should", "-"] #Thanks, Google!
  csv.each do |row|
    word = {}
    hash = row.to_hash
    if hash['language'] == "English"
      arr = hash['content'].downcase!.to_s.split(' ')
      arr.each do |word|
        word.to_s.gsub!(/\W/, "")
      end
      cont = arr.reject(&:empty?)
    else 
      cont = hash['content'].downcase!.to_s.split(' ')
    end
    cont.each do |x|
      if not common_word_arr.include? x 
        unless word.include? x
          word[x] = 0
        end
        word[x] += 1
      end
    end
    #Chack if the categories hash has the "account_category" key with the value of times that words appear
    unless categories.include? hash['account_category']
      categories[hash['account_category']] = word
    else
    #If there is no key of "word" -> create a new key with its value = 1
      word.each do |key, value|
        unless categories[hash['account_category']].include? key
          categories[hash['account_category']][key] = 0
          categories[hash['account_category']][key] += 1
        else
          #Adding the value to the value of the key
          categories[hash['account_category']][key] += value
        end
      end
    end
  end

  puts
  puts "What are the 10 most common words used by each account type?"
  puts
  
  categories.each do |key, value|
    common_word = value.sort_by { |_k, v| v }.reverse.to_a
    index = 1
    puts "10 most common words #{key} uses:"
    common_word.each do |word|
      puts "#{index}) '#{word[0]}': #{word[1]} times"
      break if index == 10
      index += 1
    end
    puts
  end
end

# This is fast for testing
count_troll_types('test-tweets.csv')
most_tweet_day('test-tweets.csv')
most_tweet_hour('test-tweets.csv')
most_common_word('test-tweets.csv')
author_most_common_word('test-tweets.csv')
most_common_word_each_type('test-tweets.csv')