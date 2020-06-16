require 'twitter'
require 'dotenv'

Dotenv.load

MAX_REQUESTS = 150

def twitter_client
  Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['YOUR_CONSUMER_KEY']
    config.consumer_secret     = ENV['YOUR_CONSUMER_SECRET']
    config.access_token        = ENV['YOUR_ACCESS_TOKEN']
    config.access_token_secret = ENV['YOUR_ACCESS_SECRET']
  end
end

def choose_friends
  file = File.open("all_friends_ids.txt")
  file_data = file.readlines.map(&:chomp)
  file_data.each do |f|
    f = f.split(',')
    puts "Deseja dar unfollow nessa conta?\n #{f[1]} Digite 1 para sim, 2 para não, 3 para não sei.\n"
    option = gets.chomp.to_i
    return unless validates_option(option)

    case option
    when 1
      File.write("logs.txt", "Você optou por dar unfollow na conta #{f[1]}.\n", mode: "a")
      File.write("list_unfollow.txt", "#{f.first}\n", mode: "a")
    when 2
      File.write("logs.txt", "Você optou por NÃO dar unfollow na conta #{f[1]}.\n", mode: "a")
    when 3
      File.write("logs.txt", "Você não sabe se vai dar na conta #{f[1]}.\n", mode: "a")
      File.write("not_decided.txt", "#{f.first}\n", mode: "a")
    end
  end
end

def validates_option(op)
  return true unless !(op == 1 || op == 2 || op == 3)
  puts "você digitou a opção errada, tente de novo:"
  option = gets.chomp.to_i
end

def unfollow_friends
  client = twitter_client

  requests = 1
  rodadas = 1

  file = File.open("list_unfollow.txt")
  file_data = file.readlines.map(&:chomp)

  file_data.each do |f|
    client.unfollow(f.to_i) rescue Twitter::Error::Forbidden
    File.write("unfollow_friends.txt", "#{f}\n", mode: "a")
    File.write("logs.txt", "Unfollow no #{f} em #{Time.now}.\n", mode: "a")
  
    puts requests
    requests += 1
  
    if requests >= MAX_REQUESTS
      File.write("logs.txt", "Sleep por 15 minutes a partir de #{Time.now}. Estamos rodando o método unfollow_friends e estamos na #{rodadas} rodada.\n", mode: "a")
      rodadas += 1
      sleep(900)
      requests = 0
    end
  end
end

File.write("logs.txt", "Iniciando o script em #{Time.now}.\n", mode: "a")

# chamando método de escolha de friends
File.write("logs.txt", "Chamando o método choose_friends em #{Time.now}.\n", mode: "a")
choose_friends

File.write("logs.txt", "Chamando o método unfollow_friends em #{Time.now}.\n", mode: "a")

unfollow_friends

File.write("logs.txt", "Script finalizado em #{Time.now}.\n", mode: "a")