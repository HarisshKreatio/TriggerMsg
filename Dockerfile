FROM ruby:3.1.2-alpine3.16

RUN mkdir -p /tmp/trigger

COPY Gemfile /tmp/trigger/
COPY Gemfile.lock /tmp/trigger/

RUN cd /tmp/trigger/ && apk add --update --upgrade git libcurl aspell-en zip libpq-dev postgresql-dev curl tar \
    wget linux-headers build-base zlib-dev libxml2-dev libxslt-dev readline-dev tzdata git nodejs && \
    bundle config git.allow_insecure true && \
    gem install bundler -v='2.3.7' && \
    bundle _2.3.7_ install -j 10 && rm -rf /tmp/*

#Copy application
COPY . /tmp/trigger
WORKDIR /tmp/trigger

ARG env
ENV env_name=$env

RUN echo "export SECRET_KEY_BASE=$(./bin/rake secret)" >> ~/.profile
RUN echo "export RAILS_ENV=${env_name}" >> ~/.profile
#RUN echo "export RAILS_SERVE_STATIC_FILES=true" >> ~/.profile

RUN source ~/.profile
EXPOSE 3050
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3050"]
