-module(roles_store).

-export([init/0]).
-export([insert_role/1]).
-export([get_role/1]).
-export([get_all_roles/0]).
-export([delete_role/1]).

-define(TABLE_NAME, roles_table).

init() ->
    ets:new(?TABLE_NAME, [set, public, named_table]),
    ok.

insert_role(Role) ->
    Id = generate_id(),
    ets:insert(?TABLE_NAME, {Id, Role}),
    {ok, Id}.

get_role(Id) ->
    case ets:lookup(?TABLE_NAME, Id) of
        [{Id, Role}] -> {ok, Role};
        [] -> {error, not_found}
    end.

get_all_roles() ->
    ets:tab2list(?TABLE_NAME).

delete_role(Id) ->
    ets:delete(?TABLE_NAME, Id).

%% Private functions
generate_id() ->
    {Mega, Sec, Micro} = os:timestamp(),
    (Mega * 1000000 + Sec) * 1000000 + Micro.