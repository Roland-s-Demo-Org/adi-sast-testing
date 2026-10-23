#FROM ruby:3.2
#RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
#RUN apt-get update && apt-get install -y shared-mime-info
#RUN mkdir /myapp
#WORKDIR /myapp
#ADD Gemfile /myapp/Gemfile
#ADD Gemfile.lock /myapp/Gemfile.lock
#RUN bundle install --verbose
#ADD . /myapp

FROM ruby:3.2

# Install required Linux packages
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  libsqlite3-dev \
  curl \
  git \
  nodejs \
  yarn

# Create app directory
WORKDIR /myapp

# Set bundler version explicitly (optional but safer)
RUN gem install bundler -v 2.5.6

# Copy only Gemfiles first to leverage Docker cache
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

# Install gems with verbose output for debugging
RUN bundle install --jobs 4 --retry 3 --verbose

# Now copy rest of the app
COPY . /myapp

RUN useradd -U -u 1000 appuser && chown -R 1000:1000 /myapp
USER 1000
