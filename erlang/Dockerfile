FROM erlang:27-alpine

RUN mkdir /app
WORKDIR /app

# Install rebar3
RUN wget https://github.com/erlang/rebar3/releases/download/3.22.1/rebar3 && \
    chmod +x rebar3 && \
    mv rebar3 /usr/local/bin/

# Copy erlang app
COPY . .

# Build dependencies
RUN rebar3 get-deps

# For development, we'll mount the source code as a volume
# and use rebar3 shell instead of a release

# Expose the port the app runs on
EXPOSE 8080

# Run in development mode
CMD ["rebar3", "shell"]
