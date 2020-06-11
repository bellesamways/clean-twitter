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

# Esse método cria as três listas que vamos trabalhar
def create_lists
  client = twitter_client

  @verified_handles = client.create_list(ENV['NAME_LIST_VERIFIED'], options = {:mode => 'private'})
  File.write("logs.txt", "Criada lista #{@verified_handles.name} em #{Time.now}.\n", mode: "a")

  @not_followed_me = client.create_list(ENV['NAME_LIST_NOT_FOLLOWED_ME'], options = {:mode => 'private'})
  File.write("logs.txt", "Criada lista #{@not_followed_me.name} em #{Time.now}.\n", mode: "a")

  @followed_me = client.create_list(ENV['NAME_LIST_FOLLOWED_ME'], options = {:mode => 'private'})
  File.write("logs.txt", "Criada lista #{@followed_me.name} em #{Time.now}.\n", mode: "a")
end

# Esse método percorre todos os friends e insere nas listas correspondentes. Você deve passar como parâmetro o seu arroba do twitter como string
def all_friends_and_lists(twitter_username)
  all_friends = []

  client = twitter_client
  
  # Começamos com requests em 0 para controlar o sleep
  requests = 0
  rodadas = 1
  
  client.friends(options = {:skip_status => true}).each do |f|
    # Inserimos todos os friends nesse array all_friends e também nesse arquivo de texto para controle
    all_friends << f
    File.write("all_friends_ids.txt", "#{f.id}\n", mode: "a")
    File.write("logs.txt", "Incluído a conta @#{f.screen_name} em todos os amigos em #{Time.now}.\n", mode: "a")
  
    # Verificamos se o friend é um arroba verificado no twitter, se sim insere na lista de verificados e no arquivo de texto
    if f.verified?
      client.add_list_member(@verified_handles, f) rescue Twitter::Error::Forbidden
      File.write("verified_handles.txt", "ID: #{f.id} | Arroba: #{f.screen_name}\n", mode: "a")
      File.write("logs.txt", "Incluído a conta @#{f.screen_name} na lista #{@verified_handles.name} em #{Time.now}.\n", mode: "a")
    end

    # Verificamos o relacionamento entre você e o friend. Se ele te seguir, incluimos na lista dos que te seguem
    if client.friendship(f, ENV['YOUR_HANDLE_TWITTER']).target.followed_by?
      client.add_list_member(@followed_me, f) rescue Twitter::Error::Forbidden
      File.write("followed_me.txt", "ID: #{f.id} | Arroba: #{f.screen_name}\n", mode: "a")
      File.write("logs.txt", "Incluído a conta @#{f.screen_name} na lista #{@followed_me.name} em #{Time.now}.\n", mode: "a")
    
    # se o friend não te seguir e não for uma arroba verificada, colocamos nessa lista de que não te seguem. (o ! é a negação)
    elsif !client.friendship(f, ENV['YOUR_HANDLE_TWITTER']).target.followed_by? && !f.verified?
      client.add_list_member(@not_followed_me, f) rescue Twitter::Error::Forbidden
      File.write("not_followed_me.txt", "ID: #{f.id} | Arroba: #{f.screen_name}\n", mode: "a")
      File.write("logs.txt", "Incluído a conta @#{f.screen_name} na lista #{@not_followed_me.name} em #{Time.now}.\n", mode: "a")
    end

    # Imprime qual é o número de requests que estamos e itera mais um
    # se você rodar esse código em uma VM, comente a linha abaixo
    puts requests
    requests += 1

    # Verifica se o número de requests é maior ou igual que o número máximo de requests e insere um sleep de 15 minutos para evitar o erro de TooManyRequests do Twitter
    if requests >= MAX_REQUESTS
      File.write("logs.txt", "Sleep por 15 minutes a partir de #{Time.now}. Estamos rodando o método all_friends_and_lists e estamos na #{rodadas} rodada.\n", mode: "a")
      rodadas += 1
      sleep(900)
      requests = 0
    end
  end
  all_friends.uniq!
end

# Esse método faz o unfollow da lista que você quer, você deve passar como parâmetro o objeto da lista
def unfollow_friends(list)
  client = twitter_client

  requests = 0
  rodadas = 1

  client.list_members(list).each do |m|
    client.unfollow(m) rescue Twitter::Error::Forbidden
    File.write("unfollow_list.txt", "ID: #{m.id} | Arroba: #{m.screen_name}\n", mode: "a")
    File.write("logs.txt", "", mode: "a")

    # Imprime qual é o número de requests que estamos e itera mais um
    # se você rodar esse código em uma VM, comente a linha abaixo
    puts requests
    requests += 1

    # Verifica se o número de requests é maior ou igual que o número máximo de requests e insere um sleep de 15 minutos para evitar o erro de TooManyRequests do Twitter
    if requests >= MAX_REQUESTS
      File.write("logs.txt", "Sleep por 15 minutes a partir de #{Time.now}. Estamos rodando o método unfollow_friends e estamos na #{rodadas} rodada.\n", mode: "a")
      rodadas += 1
      sleep(900)
      requests = 0
    end
  end
end

# Esse método faz a contagem de friends restantes após todos os unfollows
def after_friends(twitter_username)
  after_friends = []

  client = twitter_client

  requests = 0
  rodadas = 1

  client.friends(options = {:skip_status => true}).each do |f|
    # Inserimos todos os friends nesse array all_friends e também nesse arquivo de texto para controle
    after_friends << f
    File.write("after_friends.txt", "#{f.id}\n", mode: "a")
    File.write("logs.txt", "", mode: "a")

    # Imprime qual é o número de requests que estamos e itera mais um
    # se você rodar esse código em uma VM, comente a linha abaixo
    puts requests
    requests += 1

    # Verifica se o número de requests é maior ou igual que o número máximo de requests e insere um sleep de 15 minutos para evitar o erro de TooManyRequests do Twitter
    if requests >= MAX_REQUESTS
      File.write("logs.txt", "Sleep por 15 minutes a partir de #{Time.now}. Estamos rodando o método after_friends e estamos na #{rodadas} rodada.\n", mode: "a")
      rodadas += 1
      sleep(900)
      requests = 0
    end
  end
  after_friends.uniq!
end

File.write("logs.txt", "Iniciando o script em #{Time.now}.\n", mode: "a")
File.write("logs.txt", "Chamando método de criação de listas, em #{Time.now}.\n", mode: "a")

# chama o método de criar listas
create_lists

File.write("logs.txt", "Chamando método de capturar todos os friends e inserir em listas, em #{Time.now}.\n", mode: "a")

# chama o método de listas os friends
all_friends_and_lists(ENV['YOUR_HANDLE_TWITTER'])

File.write("logs.txt", "O número de friends que você tem em #{Time.now} é #{all_friends.count}.\n", mode: "a")

# chama o método de unfollow por listas
File.write("logs.txt", "Inserindo um sleep por 15 minutos para rodar o método unfollow_friends, em #{Time.now}.\n", mode: "a")

sleep(900)

File.write("logs.txt", "Chamando o método de unfollow para a lista #{@not_followed_me.name}, em #{Time.now}.\n", mode: "a")

unfollow_friends(@not_followed_me)

# se você quiser dar unfollow em mais listas, não esqueça de sempre colocar um sleep entre cada chamada de método.

File.write("logs.txt", "Inserindo um sleep por 15 minutos para rodar o método unfollow_friends, em #{Time.now}.\n", mode: "a")

sleep(900)

File.write("logs.txt", "Chamando o método de unfollow para a lista #{@followed_me.name}, em #{Time.now}.\n", mode: "a")

unfollow_friends(@followed_me)

File.write("logs.txt", "Inserindo um sleep por 15 minutos para rodar o método unfollow_friends, em #{Time.now}.\n", mode: "a")

sleep(900)

File.write("logs.txt", "Chamando o método de unfollow para a lista #{@verified_handles.name}, em #{Time.now}.\n", mode: "a")

unfollow_friends(@verified_handles)

# se você NÃO quiser saber quantos friends ficaram, comente as linhas 187 a 199.

File.write("logs.txt", "Inserindo um sleep por 15 minutos para rodar o método after_friends, em #{Time.now}.\n", mode: "a")

sleep(900)

File.write("logs.txt", "Chamando o método de contagem de friends restantes em #{Time.now}.\n", mode: "a")

after_friends(ENV['YOUR_HANDLE_TWITTER'])

File.write("results.txt", "O número de friends que você tem em #{Time.now} é #{after_friends.count}.\n", mode: "a")

number_accounts = all_friends.count - after_friends.count

File.write("results.txt", "Você deu unfollow em #{number_accounts} contas.\n", mode: "a")

# Insere o último log do script indicando que finalizou

File.write("logs.txt", "Script finalizado em #{Time.now}.\n", mode: "a")