require 'twitter'
require 'dotenv'

Dotenv.load

MAX_REQUESTS = 80

# Duplique o arquivo .env-sample e renomeie para .env
# Insira as suas chaves e outras configs

# faz a sua autenticação no twitter
client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['YOUR_CONSUMER_KEY']
    config.consumer_secret     = ENV['YOUR_CONSUMER_SECRET']
    config.access_token        = ENV['YOUR_ACCESS_TOKEN']
    config.access_token_secret = ENV['YOUR_ACCESS_SECRET']
  end

# exclui todas as listas que você tem no twitter
own_lists = []

requests = 0

client.lists(options = {:reverse => true}).each do |list|
  # verifica se a lista é sua
  if list.user.screen_name == ENV['YOUR_HANDLE_TWITTER']
    own_lists << list
    client.destroy_list(list)
  end

  # Imprime qual é o número de requests que estamos e itera mais um
  puts requests
  requests += 1

  # Verifica se o número de requests é maior ou igual que o número máximo de requests e insere um sleep de 15 minutos para evitar o erro de TooManyRequests do Twitter
  if requests >= MAX_REQUESTS
    puts "sleeping for 15 minutes"
    sleep(900)
    requests = 0
  end
end

puts "Você tinha #{own_lists.count} listas e que foram excluídas."