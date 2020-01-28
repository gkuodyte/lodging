run:
	iex -S mix phx.server

clean:
	rm -rf priv/static/* assets/node_modules deps/ mix.lock assets/yarn.lock

setup:
	mix deps.get
	cd assets && yarn install

test: dummy
	mix test --trace

dummy:

build:
	mix phx.digest
	mix compile