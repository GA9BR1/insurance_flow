FROM ruby:3.2.2

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
EXPOSE 3001
CMD ["/bin/bash", "-c", "rails s -b 0.0.0.0", "-p", "3001"]