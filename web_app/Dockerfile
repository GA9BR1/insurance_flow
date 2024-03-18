FROM ruby:3.2.2

RUN apt-get update
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .


CMD ["rackup"]
