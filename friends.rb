require 'twitter'
require 'dotenv'

Dotenv.load

MAX_REQUESTS = 80

# Duplique o arquivo .env-sample e renomeie para .env
# Insira as suas chaves e outras configs

# Esse método faz a sua autenticação no twitter
def twitter_client
  Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['YOUR_CONSUMER_KEY']
    config.consumer_secret     = ENV['YOUR_CONSUMER_SECRET']
    config.access_token        = ENV['YOUR_ACCESS_TOKEN']
    config.access_token_secret = ENV['YOUR_ACCESS_SECRET']
  end
end

# Esse método percorre todos os friends e insere nos txts correspondentes. Você deve passar como parâmetro o seu arroba do twitter como string
def all_friends(twitter_username)
  client = twitter_client
  
  # Começamos com requests em 0 para controlar o sleep
  requests = 0
  rodadas = 1
  
  client.friends(options = {:skip_status => true}).each do |f|
    # Inserimos todos os friends nesse arquivo de texto para controle
    File.write("all_friends_ids.txt", "#{f.id}, @#{f.screen_name}\n", mode: "a")
    File.write("logs.txt", "Incluído a conta @#{f.screen_name} na lista all_friends_ids em #{Time.now}.\n", mode: "a")

    # Verificamos o relacionamento entre você e o friend. Se ele te seguir, incluimos no arquivo dos que te seguem
    if client.friendship(f, twitter_username).target.followed_by?
      File.write("followed_me.txt", "#{f.id}, @#{f.screen_name}\n", mode: "a")
      File.write("logs.txt", "Incluído a conta @#{f.screen_name} no arquivo followed_me em #{Time.now}.\n", mode: "a")
    # se o friend não te seguir e não for uma arroba verificada, colocamos no arquivo de que não te seguem. (o ! é a negação)
    elsif !client.friendship(f, twitter_username).target.followed_by? && !f.verified?
      File.write("not_followed_me.txt", "#{f.id}, @#{f.screen_name}\n", mode: "a")
      File.write("logs.txt", "Incluído a conta @#{f.screen_name} no arquivo not_followed_me em #{Time.now}.\n", mode: "a")
    end

    # Imprime qual é o número de requests que estamos e itera mais um
    puts requests
    requests += 1

    # Verifica se o número de requests é maior ou igual que o número máximo de requests e insere um sleep de 15 minutos para evitar o erro de TooManyRequests do Twitter
    if requests >= MAX_REQUESTS
      File.write("logs.txt", "Sleep por 15 minutes a partir de #{Time.now}. Estamos rodando o método all_friends e estamos na #{rodadas} rodada.\n", mode: "a")
      rodadas += 1
      sleep(900)
      requests = 0
    end
  end
end

# CHAMANDO OS MÉTODOS

File.write("logs.txt", "Iniciando o script em #{Time.now}.\n", mode: "a")
File.write("logs.txt", "Chamando método de capturar todos os friends e inserir nos arquivos, em #{Time.now}.\n", mode: "a")

# chama o método de listas os friends
all_friends(ENV['YOUR_HANDLE_TWITTER'])

file = File.open("all_friends_ids.txt")

file_data = file.readlines(&:chomp)

File.write("logs.txt", "O número de friends que você tem em #{Time.now} é #{file_data.count}.\n", mode: "a")

# Insere o último log do script indicando que finalizou

File.write("logs.txt", "Script finalizado em #{Time.now}.\n", mode: "a")