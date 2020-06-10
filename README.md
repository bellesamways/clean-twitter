# Twitter Unfollower

Esse é um script em **ruby 2.6.5**.

## O que ele faz

- Pega todas as contas que você segue;
- Separa em listas (dentro do próprio twitter) de contas verificadas, contas que você segue e não te seguem e contas que você segue e eles segue de volta.
- Para chamar a lista que você quer dar unfollow, na linha XXX, o parâmetro a ser passado é o objeto da lista. Por exemplo: 

```ruby
unfollow_friends(verificados)
```

- Para chamar mais de uma lista, chame o método novamente. Por exemplo:

```ruby
unfollow_friends(verificados)
unfollow_friends(naomesegue)
```

- Quando você cria uma lista com as contas, mesmo que dê unfollow, elas não sairão da lista. Portanto, caso você de unfollow sem querer, ainda é possível dar follow de novo.

- Caso você tenha muitas contas que você segue, uma opção é subir esse código em uma VM e executar nela, assim não ocupa processamento do seu PC e você pode deixar rodando por mais tempo (por conta do limite do twitter).

- O código gera alguns arquivos em .txt para validação das contas que você mexeu. Todos os arquivos ficarão na raiz do projeto. PS: *Caso você tenha que rodar mais de uma vez o código, lembre-se de deletar os arquivos antes.*

## Instalação

Baixe o repositório na sua máquina com:

```bash
git clone
```

Entre na pasta criada com:

```bash
cd 
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

```bash
ruby unfollow.rb
```

## Observações

Dependendo da quantidade de contas que você segue, pode levar pouco ou muito tempo. Isso acontece por conta, de novo, do limite de requisições do twitter.

## Dúvidas

Abre uma issue!

## Usou o script

[Me marca no twitter](https://twitter.com/bellesamways)!
