FROM ruby:3.2.2

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
CMD ["/bin/bash", "-c", "rails s -b 0.0.0.0"]