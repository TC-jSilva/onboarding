-module(roles_store_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("erlang/include/records.hrl").

setup() ->
    meck:new(redis_client),
    ok.

teardown() ->
    meck:unload(redis_client),
    ok.

roles_store_test() ->
    {foreach,
     fun setup/0,
     fun teardown/0,
     [
      {"insert_role should create a new role",
       fun() ->
           Role = #role{event_type = test, data = #data{first_name = "John"}},
           meck:expect(redis_client, get, fun("roles:keys") -> {ok, undefined} end),
           meck:expect(redis_client, set, fun(_, _) -> {ok, <<"OK">>} end),
           {ok, Id} = roles_store:insert_role(Role),
           ?assert(is_binary(Id))
       end},
      {"get_all_roles should return empty list when no roles exist",
       fun() ->
           meck:expect(redis_client, get, fun("roles:keys") -> {ok, undefined} end),
           {ok, Roles} = roles_store:get_all_roles(),
           ?assertEqual([], Roles)
       end},
      {"get_all_roles should return list of roles",
       fun() ->
           Role = #role{event_type = test, data = #data{first_name = "John"}},
           RoleBin = term_to_binary(Role),
           meck:expect(redis_client, get,
                      fun("roles:keys") -> {ok, <<"role:1">>};
                         ("role:1") -> {ok, RoleBin}
                      end),
           {ok, Roles} = roles_store:get_all_roles(),
           ?assertEqual([{1, Role}], Roles)
       end},
      {"delete_role should remove existing role",
       fun() ->
           meck:expect(redis_client, get,
                      fun("roles:keys") -> {ok, <<"role:1">>} end),
           meck:expect(redis_client, delete, fun(_) -> {ok, 1} end),
           meck:expect(redis_client, set, fun(_, _) -> {ok, <<"OK">>} end),
           ok = roles_store:delete_role(1)
       end},
      {"update_role should modify existing role",
       fun() ->
           Role = #role{event_type = test, data = #data{first_name = "John"}},
           meck:expect(redis_client, get,
                      fun("roles:keys") -> {ok, <<"role:1">>} end),
           meck:expect(redis_client, set, fun(_, _) -> {ok, <<"OK">>} end),
           ok = roles_store:update_role(1, Role)
       end},
      {"get_role should return existing role",
       fun() ->
           Role = #role{event_type = test, data = #data{first_name = "John"}},
           RoleBin = term_to_binary(Role),
           meck:expect(redis_client, get,
                      fun("role:1") -> {ok, RoleBin} end),
           {ok, RetrievedRole} = roles_store:get_role(1),
           ?assertEqual(Role, RetrievedRole)
       end},
      {"get_role should return not_found for non-existent role",
       fun() ->
           meck:expect(redis_client, get,
                      fun("role:1") -> {ok, undefined} end),
           {error, not_found} = roles_store:get_role(1)
       end}
     ]}.
