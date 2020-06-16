# Twitter Unfollower

Esse é um script em **ruby 2.6.5**.

## O que o friends.rb faz

- Pega todas as contas que você segue;
- Salva em um txt algumas informações das contas que você segue;
- Cada sleep é de 15 minutos a cada 80 requisições (ele faz 2 ou 3 requisições para o twitter enquanto esse código roda);
- O código gera alguns arquivos em .txt para validação das contas que você mexeu. Todos os arquivos ficarão na raiz do projeto. PS: *Caso você tenha que rodar mais de uma vez o código, lembre-se de deletar os arquivos antes.*
- *Todos os logs de execução estarão no arquivo `logs.txt`.*

## O que o unfollow.rb faz

- Depois de rodar o `friends.rb`, você salvou todos os seus friends no arquivo `all_friends_ids.txt`;
- Você vai ter salvo todos os seus friends nesse txt, então nesse método você vai escolher em quem vai dar unfollow;
- Se você colocar 1, ele será colocado na lista de unfollow, se colocar 2 não será colocado em lista alguma e se escolher 3, será colocado na lista de não decididos;
- Após fazer todas as escolhas, o método unfollow_friends irá rodar automaticamente pegando todos os friends que você colocou na lista de unfollow e dando unfollow em cada um;
- Uma nova lista de log será gerada no arquivo `unfollow_friends.txt`.
- *Todos os logs de execução estarão no arquivo `logs.txt`.*

## O que o lists_destroy_all.rb faz

- Ele exclui todas as listas que você é o dono.
- *Todos os logs de execução estarão no arquivo `logs.txt`.*

## Instalação

Baixe o repositório na sua máquina com:

```bash
git clone git@github.com:bellesamways/clean-twitter.git
```

Entre na pasta criada com:

```bash
cd clean-twitter
```

### Instale as dependências

#### Ruby 2.6.5

[Usando RVM](https://www.ruby-lang.org/pt/documentation/installation/#rvm)

[Usando Rbenv](https://www.ruby-lang.org/pt/documentation/installation/#rbenv)

[Usando ASDF](https://github.com/asdf-vm/asdf-ruby)

#### Gems

Rode no terminal:

```bash
gem install twitter
gem install dotenv
```

Copie o conteúdo do arquivo `.env-sample` e crie um novo arquivo `.env` com as suas credenciais do [twitter para devs](https://developer.twitter.com/en).

## Rodando o script

Dentro da pasta do projeto, no terminal, rode:

- Para pegar todos os amigos e colocar na lista de friends:

```bash
ruby friends.rb
```

- Para fazer o unfollow (depois de rodar o friends.rb):

```bash
ruby unfollow.rb
```

- Para excluir as listas:

```bash
ruby lists_destroy_all.rb
```

## Observações

Dependendo da quantidade de contas que você segue, pode levar pouco ou muito tempo. Isso acontece por conta, de novo, do limite de requisições do twitter. Existem outras abordagens que pode ser mais rápido.

Para dúvidas, abra uma issue ou me chame no [twitter](https://twitter.com/bellesamways). Se você usou o script, [me marca no twitter](https://twitter.com/bellesamways)!

Se quiser me pagar um café pelo trabalho: [Picpay](https://picpay.me/isabelle.samways)
