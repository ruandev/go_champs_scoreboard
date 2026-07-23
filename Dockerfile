ARG ELIXIR_VERSION=1.17.2
ARG OTP_VERSION=27.0
ARG DEBIAN_VERSION=bookworm-20260610-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update -y && apt-get install -y build-essential git curl nodejs npm \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

COPY package.json package-lock.json ./
RUN npm ci

COPY priv priv
COPY lib lib
COPY assets assets

RUN mix assets.deploy

COPY config/runtime.exs config/
RUN mix release

FROM ${RUNNER_IMAGE} AS runner

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

RUN chown nobody /app

ENV MIX_ENV="prod"
ENV PHX_SERVER=true

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/go_champs_scoreboard ./

USER nobody

EXPOSE 4000

CMD ["/app/bin/go_champs_scoreboard", "start"]
