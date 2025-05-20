-module(roles_supervisor).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {{one_for_one, 5, 10}, [
        {redis_client, {redis_client, start_link, []}, permanent, 5000, worker, [redis_client]},
        {roles_store, {roles_store, start_link, []}, permanent, 5000, worker, [roles_store]}
    ]}}.