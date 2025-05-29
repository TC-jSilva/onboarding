-module(erlang_get_handler_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("erlang/include/records.hrl").

setup() ->
    meck:new(roles_store),
    meck:new(role_json),
    ok.

teardown(_) ->
    meck:unload(roles_store),
    meck:unload(role_json),
    ok.

erlang_get_handler_test() ->
    {foreach,
     fun setup/0,
     fun teardown/1,
     [
      {"should only allow GET method",
       fun() ->
           {Methods, _, _} = erlang_get_handler:allowed_methods(#{}, []),
           ?assertEqual([<<"GET">>], Methods)
       end},
      {"should provide application/json content type",
       fun() ->
           {ContentTypes, _, _} = erlang_get_handler:content_types_provided(#{}, []),
           ?assertEqual([{<<"application/json">>, to_json}], ContentTypes)
       end},
      {"should return roles as JSON on successful retrieval",
       fun() ->
           % Mock roles data
           Roles = [{1, #role{event_type = <<"test">>, data = #data{first_name = <<"John">>}}}],
           JsonRoles = <<"[{\"id\":1,\"event_type\":\"test\",\"data\":{\"first_name\":\"John\"}}]">>,

           % Setup mocks
           meck:expect(roles_store, get_all_roles, fun() -> {ok, Roles} end),
           meck:expect(role_json, roles_to_json, fun(R) -> JsonRoles end),

           % Call the function
           {Result, _, _} = erlang_get_handler:to_json(#{}, []),

           % Verify results
           ?assertEqual(JsonRoles, Result),
           ?assert(meck:called(roles_store, get_all_roles, [])),
           ?assert(meck:called(role_json, roles_to_json, [Roles]))
       end},
      {"should handle error when retrieving roles",
       fun() ->
           % Setup mocks
           meck:expect(roles_store, get_all_roles, fun() -> {error, <<"test error">>} end),

           % Call the function
           {halt, Req, _} = erlang_get_handler:to_json(#{}, []),

           % Verify results
           ?assert(meck:called(roles_store, get_all_roles, [])),
           ?assertNot(meck:called(role_json, roles_to_json, '_'))
       end}
     ]}.
