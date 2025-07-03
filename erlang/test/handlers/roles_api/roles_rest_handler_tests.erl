-module(roles_rest_handler_tests).

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

roles_rest_handler_test() ->
    {foreach,
     fun setup/0,
     fun teardown/1,
     [
      {"should handle GET request for existing role",
       fun() ->
           % Mock role data
           RoleId = 1,
           Role = #role{event_type = <<"test">>, data = #data{first_name = <<"John">>}},
           JsonRole = <<"{\"id\":1,\"event_type\":\"test\",\"data\":{\"first_name\":\"John\"}}">>,

           % Setup mocks
           meck:expect(roles_store, get_role, fun(Id) -> {ok, Role} end),
           meck:expect(role_json, roles_to_json, fun(Roles) -> JsonRole end),

           % Mock cowboy_req functions
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, method, fun(Req) -> <<"GET">> end),
           meck:expect(cowboy_req, path, fun(Req) -> <<"/staff/roles/1">> end),
           meck:expect(cowboy_req, reply, fun(200, Headers, Body, Req) ->
               ?assertEqual(#{<<"content-type">> => <<"application/json">>}, Headers),
               ?assertEqual(JsonRole, Body),
               Req
           end),

           % Call the function
           {ok, _, _} = roles_rest_handler:init(#{}, []),

           % Verify results
           ?assert(meck:called(roles_store, get_role, [RoleId])),
           ?assert(meck:called(role_json, roles_to_json, [[{RoleId, Role}]])),

           % Cleanup
           meck:unload(cowboy_req)
       end},
      {"should handle GET request for non-existent role",
       fun() ->
           % Setup mocks
           meck:expect(roles_store, get_role, fun(_) -> {error, not_found} end),

           % Mock cowboy_req functions
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, method, fun(Req) -> <<"GET">> end),
           meck:expect(cowboy_req, path, fun(Req) -> <<"/staff/roles/999">> end),
           meck:expect(cowboy_req, reply, fun(404, Headers, Body, Req) ->
               ?assertEqual(#{<<"content-type">> => <<"application/json">>}, Headers),
               ?assertEqual(json:encode(#{<<"error">> => <<"Role not found">>}), Body),
               Req
           end),

           % Call the function
           {ok, _, _} = roles_rest_handler:init(#{}, []),

           % Verify results
           ?assert(meck:called(roles_store, get_role, [999])),

           % Cleanup
           meck:unload(cowboy_req)
       end},
      {"should handle DELETE request for existing role",
       fun() ->
           % Setup mocks
           meck:expect(roles_store, delete_role, fun(_) -> ok end),

           % Mock cowboy_req functions
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, method, fun(Req) -> <<"DELETE">> end),
           meck:expect(cowboy_req, path, fun(Req) -> <<"/staff/roles/1">> end),
           meck:expect(cowboy_req, reply, fun(204, _, _, Req) -> Req end),

           % Call the function
           {ok, _, _} = roles_rest_handler:init(#{}, []),

           % Verify results
           ?assert(meck:called(roles_store, delete_role, [1])),

           % Cleanup
           meck:unload(cowboy_req)
       end},
      {"should handle PUT request to update role",
       fun() ->
           % Mock role data
           RoleId = 1,
           JsonBody = <<"{\"event_type\":\"test\",\"data\":{\"first_name\":\"John\"}}">>,
           Role = #role{event_type = <<"test">>, data = #data{first_name = <<"John">>}},

           % Setup mocks
           meck:expect(role_json, json_to_role, fun(Body) -> {ok, Role} end),
           meck:expect(roles_store, update_role, fun(Id, R) -> ok end),

           % Mock cowboy_req functions
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, method, fun(Req) -> <<"PUT">> end),
           meck:expect(cowboy_req, path, fun(Req) -> <<"/staff/roles/1">> end),
           meck:expect(cowboy_req, read_body, fun(Req) -> {ok, JsonBody, Req} end),
           meck:expect(cowboy_req, reply, fun(200, Headers, Body, Req) ->
               ?assertEqual(#{<<"content-type">> => <<"application/json">>}, Headers),
               ?assertEqual(json:encode(#{<<"message">> => <<"Role updated successfully">>}), Body),
               Req
           end),

           % Call the function
           {ok, _, _} = roles_rest_handler:init(#{}, []),

           % Verify results
           ?assert(meck:called(role_json, json_to_role, [JsonBody])),
           ?assert(meck:called(roles_store, update_role, [RoleId, Role])),

           % Cleanup
           meck:unload(cowboy_req)
       end},
      {"should handle invalid role ID",
       fun() ->
           % Mock cowboy_req functions
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, method, fun(Req) -> <<"GET">> end),
           meck:expect(cowboy_req, path, fun(Req) -> <<"/staff/roles/invalid">> end),
           meck:expect(cowboy_req, reply, fun(400, Headers, Body, Req) ->
               ?assertEqual(#{<<"content-type">> => <<"application/json">>}, Headers),
               ?assertEqual(json:encode(#{<<"error">> => <<"Invalid role ID">>}), Body),
               Req
           end),

           % Call the function
           {ok, _, _} = roles_rest_handler:init(#{}, []),

           % Verify results
           ?assertNot(meck:called(roles_store, get_role, '_')),

           % Cleanup
           meck:unload(cowboy_req)
       end},
      {"should handle invalid request method",
       fun() ->
           % Mock cowboy_req functions
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, method, fun(Req) -> <<"PATCH">> end),
           meck:expect(cowboy_req, path, fun(Req) -> <<"/staff/roles/1">> end),
           meck:expect(cowboy_req, reply, fun(404, Headers, Body, Req) ->
               ?assertEqual(#{<<"content-type">> => <<"application/json">>}, Headers),
               ?assertEqual(json:encode(#{<<"error">> => <<"Not found">>}), Body),
               Req
           end),

           % Call the function
           {ok, _, _} = roles_rest_handler:init(#{}, []),

           % Verify results
           ?assertNot(meck:called(roles_store, '_', '_')),

           % Cleanup
           meck:unload(cowboy_req)
       end}
     ]}.
