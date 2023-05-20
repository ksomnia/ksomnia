# Ksomnia

Ksomnia is an open source error tracking software. More on https://ksomnia.com. Installation guide https://ksomnia.com/installation/.

![ScreenShot](https://ksomnia.com/ksomnia-ui-screenshot.png)

### Development

Install the latest Elixir, Erlang, NodeJS, Meilisearch, ClickHouse and PostgreSQL. Use [asdf.vm](https://asdf-vm.com/) or follow the instructions from the installation guide https://ksomnia.com/installation/#install-erlang-elixir-and-nodejs.

Install the dependencies

```
mix deps.get
mix ecto.setup
cd assets && yarn
cd source_mapper && yarn
cd dev_extras/sample_app && mix deps.get
cd dev_extras/sample_app/assets && yarn
```

Run [Procfile](https://devcenter.heroku.com/articles/procfile) with your preferred process runner

```
foreman -f 'Procfile.dev' start
```

Connect to the server via `iex --sname ksomnia_shell --remsh ksomnia`
