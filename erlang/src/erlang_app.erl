-module(erlang_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    case roles_supervisor:start_link() of
        {ok, Pid} ->
            % Then start Cowboy
            Dispatch =
                cowboy_router:compile([{'_',
                                        [{"/staff/roles", erlang_get_handler, []},
                                         {"/staff/roles/create", erlang_post_handler, []},
                                         {"/staff/roles/:id", roles_rest_handler, []}]}]),
            {ok, _} =
                cowboy:start_clear(roles_rest_listener,
        [{port, 8080}],
                                   #{env => #{dispatch => Dispatch}}),
            {ok, Pid};
        Error ->
            Error
    end.

stop(_State) ->
    ok.
