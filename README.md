[![CircleCI](https://circleci.com/gh/4doctors/moodle_lib.svg?style=svg&circle-token=19b5cb16193a29ba11104117e01c0a3df6bfe8e7)](https://circleci.com/gh/4doctors/moodle_lib)

# MoodleLib

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `moodle_lib` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:moodle_lib, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/moodle_lib](https://hexdocs.pm/moodle_lib).

## Setup Moodle test environment

disclaimer: Right now the library is in its initial stages and the process is a
bit clumsy, this shall be improved in the future.

steps:

1. Download docker files to build a Moodle instance

```
git clone https://github.com/jmhardison/docker-moodle
cd docker-moodle
docker build -t moodle .
```

2. Spin up the docker images. To spawn a new instance of Moodle (if no tag is specified it will run `latest` by default):

```
docker run -d --name DB -p 3306:3306 -e MYSQL_DATABASE=moodle -e MYSQL_ROOT_PASSWORD=moodle -e MYSQL_USER=moodle -e MYSQL_PASSWORD=moodle mysql:5

docker run -d -P --name moodle --link DB:DB -e MOODLE_URL=http://localhost:8080 -p 8080:80 jhardison/moodle
```

3. Run Moodle's initial setup and enable `Web Services` under `plugins`.

4. Setup a new user to use the web services and get a token.

5. Paste the token to the `:token` key on `config.exs`
