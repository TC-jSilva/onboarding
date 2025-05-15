-module(erlang_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/staff/roles", erlang_get_all_handler, []},
            {"/staff/roles/create", erlang_post_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(erlang_rest_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
	erlang_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(erlang_rest_listener).
