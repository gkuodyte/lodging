# Lodging
A tailored booking system for hospitality and catering service providers and users. Created as a prototype alongside my bachelors dissertation for researching existing booking systems, their functionality and limitations. Built using Elixir and Phoenix and deployed via Heroku.


## Learn more
To start this Phoenix server:

* Clone this repository
* Install Elixir following these steps https://elixir-lang.org/install.html
* Install Erlang following these steps (if it was not already installed with previous step) https://elixir-
lang.org/install.html#installing-erlang
* Install nodejs using this https://nodejs.org/en/download/
* Install PostgreSQL following this guide https://wiki.postgresql.org/wiki/Detailed_installation_guides
* Install yarn following this guide https://yarnpkg.com/getting-started/install or npm if yarn is not
compatible with your operating system

At the root of the application, run these commands in the terminal:
* `mix deps.get` to get all required dependencies
* `mix deps.compile` to compile the dependencies
* `cd assets && yarn install` to install the assets
* `mix ecto.create` to create the database
* `mix ecto.migrate` to migrate the database changes
* `make` to run the application (or mix phx.server if make doesn’t work)
* Access the application in your browser on `localhost:4000`

More information and instructions can be found here https://hexdocs.pm/phoenix/ up_and_running.html#content
