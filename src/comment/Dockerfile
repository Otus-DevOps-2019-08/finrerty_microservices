FROM ruby:2.2-alpine
ENV APP_HOME /app
RUN apk --update add --no-cache --virtual run-dependencies \
    bash \
    build-base \
    tzdata \
    && mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
COPY . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
