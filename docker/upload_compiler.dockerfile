FROM elixir:1.10

ARG MIX_ENV=dev

ENV SPIRE_SQS_QUEUE_URL does_not_matter
ENV STEAM_API_KEY does_not_matter
ENV DATABASE_URL=does_not_matter
ENV MIX_ENV=${MIX_ENV}

RUN \
  mkdir /app/ && \
  mkdir /app/apps

WORKDIR /app/

COPY mix.exs mix.lock ./
ADD ./config ./config/
ADD ./apps/upload_compiler ./apps/upload_compiler/
ADD ./apps/spire_logger ./apps/spire_logger/
ADD ./apps/spire_db ./apps/spire_db/
ADD ./apps/utils ./apps/utils/

RUN mix do local.hex --force, local.rebar --force
RUN mix do deps.get, compile