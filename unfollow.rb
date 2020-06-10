require 'twitter'
require 'dotenv'

Dotenv.load

MAX_REQUESTS = 100

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

# Esse método cria as três listas que vamos trabalhar
def create_lists
  verified_handles = client.create_list(ENV['NAME_LIST_VERIFIED'], options = {:mode => 'private'})

  not_followed_me = client.create_list(ENV['NAME_LIST_NOT_FOLLOWED_ME'], options = {:mode => 'private'})

  followed_me = client.create_list(ENV['NAME_LIST_FOLLOWED_ME'], options = {:mode => 'private'})
end

# Esse método percorre todos os friends e insere nas listas correspondentes. Você deve passar como parâmetro o seu arroba do twitter como string
def all_friends_and_lists(twitter_username)
  all_friends = []

  client = twitter_client
  
  # Começamos com requests em 0 para controlar o sleep
  requests = 0
  
  client.friends(options = {:skip_status => true}).each do |f|
    # Inserimos todos os friends nesse array all_friends e também nesse arquivo de texto para controle
    all_friends << f
    File.write("all_friends_ids.txt", "#{f.id}\n", mode: "a")
  
    # Verificamos se o friend é um arroba verificado no twitter, se sim insere na lista de verificados e no arquivo de texto
    if f.verified?
      client.add_list_member(verified_handles, f) 
      File.write("verified_handles.txt", "ID: #{f.id} | Arroba: #{f.screen_name}\n", mode: "a")
    end

    # Verificamos o relacionamento entre você e o friend. Se ele te seguir, incluimos na lista dos que te seguem
    if client.friendship(f, ENV['YOUR_HANDLE_TWITTER']).target.followed_by?
      client.add_list_member(followed_me, f)
      File.write("followed_me.txt", "ID: #{f.id} | Arroba: #{f.screen_name}\n", mode: "a")
    
    # se o friend não te seguir e não for uma arroba verificada, colocamos nessa lista de que não te seguem. (o ! é a negação)
    elsif !client.friendship(f, ENV['YOUR_HANDLE_TWITTER']).target.followed_by? && !f.verified?
      client.add_list_member(not_followed_me, f)
      File.write("not_followed_me.txt", "ID: #{f.id} | Arroba: #{f.screen_name}\n", mode: "a")
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
end

# Esse método faz o unfollow da lista que você quer, você deve passar como parâmetro o objeto da lista
def unfollow_friends(list)
  client = twitter_client

  client.list_members(list).each do |m|
    client.unfollow(m)
    File.write("unfollow_list.txt", "Nome da lista: #{list.name} | ID: #{m.id} | Arroba: #{m.screen_name}\n", mode: "a")

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
end

def after_friends(twitter_username)
  after_friends = []

  client = twitter_client

  requests = 0

  client.friends(options = {:skip_status => true}).each do |f|
    # Inserimos todos os friends nesse array all_friends e também nesse arquivo de texto para controle
    after_friends << f
    File.write("after_friends.txt", "#{f.id}\n", mode: "a")

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
end

# chama o método de criar listas
create_lists

# chama o método de listas os friends
all_friends_and_lists(ENV['YOUR_HANDLE_TWITTER'])

# imprime o número de friends que você incluiu naquele array
puts "O número de friends que você tem no momento é #{all_friends.count}"

# chama o método de unfollow por listas
unfollow_friends(not_followed_me)

# se você quiser dar unfollow em mais listas, descomente as linhas abaixo (não esqueça de sempre colocar um sleep entre cada chamada de método)

# sleep(900)
# unfollow_friends(followed_me)

# sleep(900)
# unfollow_friends(verified_handles)

# se você quiser saber quantos friends ficaram, descomente as linhas abaixo

# sleep(900)
# after_friends(ENV['YOUR_HANDLE_TWITTER'])
# puts "O número de friends que você tem no momento é #{after_friends.count}"
# number_accounts = all_friends.count - after_friends.count
# puts "Você deu unfollow em #{number_accounts} contas."