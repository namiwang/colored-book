require 'dotenv/load'

require 'google/cloud/language'
language = Google::Cloud::Language.new

book = File.read './samples/a study in scarlet.txt'

paragraphs = book.gsub!("\r\n", "\n").split("\n\n").each(&:strip!).compact.map{ |p| { text: p, words: p.split.size } }

puts paragraphs.count


File.open('./results/a study in scarlet.txt', "w+") do |f|
  paragraphs.each_with_index do |p, index|
    p[:sentiment] = language.analyze_sentiment( content: p[:text], type: :PLAIN_TEXT ).document_sentiment

    puts "index: #{index}"
    puts "words: #{p[:words]}"
    puts "score: #{p[:sentiment].score}, #{p[:sentiment].magnitude}"

    f.puts "index: #{index}"
    f.puts "words: #{p[:words]}"
    f.puts "score: #{p[:sentiment].score}, #{p[:sentiment].magnitude}"
  end
end

require 'csv'

CSV.open('./results/a study in scarlet.csv', "w+") do |csv|
  csv << ['words', 'sentiment_score', 'sentiment_magnitude']

  paragraphs.each do |p|
    csv << [p[:words], p[:sentiment].score, p[:sentiment].magnitude]
  end
end
