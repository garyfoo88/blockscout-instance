FROM bitwalker/alpine-elixir-phoenix:1.10.3

RUN apk --no-cache --update add alpine-sdk gmp-dev automake libtool inotify-tools autoconf python

EXPOSE 4000

ENV PORT='{:system, "PORT"}' \
    MIX_ENV="dev" \
    SECRET_KEY_BASE="RMgI4C1HSkxsEjdhtGMfwAHfyT6CKWXOgzCboJflfSm4jeAlic52io05KB6mqzc5" \
    ETHEREUM_JSONRPC_VARIANT="besu" \
    ETHEREUM_JSONRPC_HTTP_URL="https://a0ssv9trgy:DiXJ3k4BIhWbOL7XOGAM_Jo_OyCF9mVNPqHVczFJg0o@a0htc129vo-a0w4m2lrpx-rpc.au0-aws.kaleido.io" \
    ETHEREUM_JSONRPC_WS_URL="wss://a0ssv9trgy:DiXJ3k4BIhWbOL7XOGAM_Jo_OyCF9mVNPqHVczFJg0o@a0htc129vo-a0w4m2lrpx-wss.au0-aws.kaleido.io" \
    SHOW_PRICE_CHART="false"

# Cache elixir deps
ADD mix.exs mix.lock ./
ADD apps/block_scout_web/mix.exs ./apps/block_scout_web/
ADD apps/explorer/mix.exs ./apps/explorer/
ADD apps/ethereum_jsonrpc/mix.exs ./apps/ethereum_jsonrpc/
ADD apps/indexer/mix.exs ./apps/indexer/

RUN mix do deps.get, local.rebar --force, deps.compile

ADD . .

ARG COIN
RUN if [ "$COIN" != "" ]; then sed -i s/"POA"/"${COIN}"/g apps/block_scout_web/priv/gettext/en/LC_MESSAGES/default.po; fi

# Run forderground build and phoenix digest
RUN mix compile

# Add blockscout npm deps
RUN cd apps/block_scout_web/assets/ && \
    npm install && \
    npm run deploy && \
    cd -

RUN cd apps/explorer/ && \
    npm install && \
    apk update && apk del --force-broken-world alpine-sdk gmp-dev automake libtool inotify-tools autoconf python

# RUN mix do ecto.drop --force, ecto.create, ecto.migrate

RUN mix phx.digest

# USER default

CMD ["mix", "phx.server"]
