-module(erlang_post_handler_tests).

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

erlang_post_handler_test() ->
    {foreach,
     fun setup/0,
     fun teardown/1,
     [
      {"should only allow POST method",
       fun() ->
           {Methods, _, _} = erlang_post_handler:allowed_methods(#{}, []),
           ?assertEqual([<<"POST">>], Methods)
       end},
      {"should accept application/json content type",
       fun() ->
           {ContentTypes, _, _} = erlang_post_handler:content_types_accepted(#{}, []),
           ?assertEqual([{<<"application/json">>, from_json}], ContentTypes)
       end},
      {"should successfully create a new role",
       fun() ->
           % Mock request body and role data
           JsonBody = <<"{\"event_type\":\"test\",\"data\":{\"first_name\":\"John\"}}">>,
           Role = #role{event_type = <<"test">>, data = #data{first_name = <<"John">>}},
           RoleId = <<"123456">>,

           % Setup mocks
           meck:expect(role_json, json_to_role, fun(Body) -> {ok, Role} end),
           meck:expect(roles_store, insert_role, fun(R) -> {ok, RoleId} end),

           % Mock cowboy_req:read_body
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, read_body, fun(Req) -> {ok, JsonBody, Req} end),
           meck:expect(cowboy_req, reply, fun(201, Headers, Body, Req) ->
               ?assertEqual(#{<<"content-type">> => <<"application/json">>}, Headers),
               ?assertEqual(json:encode(#{id => RoleId, message => <<"Role created successfully">>}), Body),
               Req
           end),

           % Call the function
           {ok, _, _} = erlang_post_handler:from_json(#{}, []),

           % Verify results
           ?assert(meck:called(role_json, json_to_role, [JsonBody])),
           ?assert(meck:called(roles_store, insert_role, [Role])),

           % Cleanup
           meck:unload(cowboy_req)
       end},
      {"should handle invalid JSON",
       fun() ->
           % Mock request body
           JsonBody = <<"invalid json">>,

           % Setup mocks
           meck:expect(role_json, json_to_role, fun(Body) -> {error, <<"Invalid JSON">>} end),

           % Mock cowboy_req:read_body
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, read_body, fun(Req) -> {ok, JsonBody, Req} end),
           meck:expect(cowboy_req, reply, fun(400, Headers, Body, Req) ->
               ?assertEqual(#{<<"content-type">> => <<"application/json">>}, Headers),
               ?assertEqual(json:encode(#{error => <<"Invalid JSON">>}), Body),
               Req
           end),

           % Call the function
           {ok, _, _} = erlang_post_handler:from_json(#{}, []),

           % Verify results
           ?assert(meck:called(role_json, json_to_role, [JsonBody])),
           ?assertNot(meck:called(roles_store, insert_role, '_')),

           % Cleanup
           meck:unload(cowboy_req)
       end},
      {"should handle role store error",
       fun() ->
           % Mock request body and role data
           JsonBody = <<"{\"event_type\":\"test\",\"data\":{\"first_name\":\"John\"}}">>,
           Role = #role{event_type = <<"test">>, data = #data{first_name = <<"John">>}},

           % Setup mocks
           meck:expect(role_json, json_to_role, fun(Body) -> {ok, Role} end),
           meck:expect(roles_store, insert_role, fun(R) -> {error, <<"store error">>} end),

           % Mock cowboy_req:read_body
           meck:new(cowboy_req, [passthrough]),
           meck:expect(cowboy_req, read_body, fun(Req) -> {ok, JsonBody, Req} end),
           meck:expect(cowboy_req, reply, fun(500, Headers, Body, Req) ->
               ?assertEqual(#{<<"content-type">> => <<"application/json">>}, Headers),
               ?assertEqual(json:encode(#{error => <<"store error">>}), Body),
               Req
           end),

           % Call the function
           {ok, _, _} = erlang_post_handler:from_json(#{}, []),

           % Verify results
           ?assert(meck:called(role_json, json_to_role, [JsonBody])),
           ?assert(meck:called(roles_store, insert_role, [Role])),

           % Cleanup
           meck:unload(cowboy_req)
       end}
     ]}.
