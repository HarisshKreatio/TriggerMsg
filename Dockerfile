FROM ruby:3.1.2-alpine3.16

RUN apk add --update --upgrade \
    bash \
    git \
    libcurl \
    aspell-en \
    zip \
    libpq-dev \
    postgresql-dev \
    curl \
    tar \
    wget \
    linux-headers \
    build-base \
    zlib-dev \
    libxml2-dev \
    libxslt-dev \
    readline-dev \
    tzdata \
    nodejs \
    && bundle config git.allow_insecure true \
    && gem install bundler -v='2.3.7' \
    && mkdir -p /tmp/trigger \
    && rm -rf /var/cache/apk/*

WORKDIR /tmp/trigger

COPY . /tmp/trigger

RUN cd /tmp/trigger/ && \
    bundle _2.3.7_ install -j 10

COPY entrypoint.sh /usr/bin/
RUN #chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

EXPOSE 3050
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3050"]
