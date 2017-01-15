FROM elixir:1.4

WORKDIR /usr/src/app
COPY . /usr/src/app

EXPOSE 4273

RUN mix local.hex --force
RUN mix deps.get

CMD ["mix", "run", "--no-halt"]
