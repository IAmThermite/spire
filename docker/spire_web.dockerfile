FROM node:10.9-alpine as build-node

# prepare build dir
RUN mkdir -p /app/apps/spire/assets
WORKDIR /app/apps/spire/

# install npm dependencies
COPY ./apps/spire/assets/package.json ./apps/spire/assets/package-lock.json ./assets/
COPY ./deps/phoenix ../../deps/phoenix
COPY ./deps/phoenix_html ../../deps/phoenix_html
RUN cd assets && npm install

# build assets
COPY ./apps/spire/assets ./assets/
RUN cd assets && npm run deploy



FROM elixir:1.10 as build_elixir

ARG MIX_ENV=dev

ENV SPIRE_SQS_QUEUE_URL does_not_matter
ENV STEAM_API_KEY does_not_matter
ENV DATABASE_URL=does_not_matter
ENV SECRET_KEY_BASE=does_not_matter
ENV MIX_ENV=${MIX_ENV}

RUN \
  mkdir /app/ && \
  mkdir /app/apps

WORKDIR /app/

COPY mix.exs mix.lock ./
ADD ./config ./config/
ADD ./apps/spire ./apps/spire/
ADD ./apps/spire_logger ./apps/spire_logger/
ADD ./apps/spire_db ./apps/spire_db/
ADD ./apps/utils ./apps/utils/

COPY --from=build-node /app/apps/spire/priv/static ./apps/spire/priv/static

RUN mix do local.hex --force, local.rebar --force
RUN mix do deps.get, compile

EXPOSE 4000