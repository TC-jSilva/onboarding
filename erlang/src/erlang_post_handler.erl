-module(erlang_post_handler).

-include("../include/records.hrl").

-export([init/2]).
-export([content_types_accepted/2]).
-export([allowed_methods/2]).
-export([from_json/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, from_json}], Req, State}.

from_json(Req, State) ->
    {ok, Body, Req2} = cowboy_req:read_body(Req),
    case role_json:json_to_role(Body) of
        {ok, Role} ->
            roles_store:insert_role(Role),
            Req3 = cowboy_req:reply(201, #{
                <<"content-type">> => <<"application/json">>
            }, json:encode(#{<<"message">> => <<"Role created successfully">>}), Req2),
            {true, Req3, State};
        _ ->
            Req3 = cowboy_req:reply(400, #{
                <<"content-type">> => <<"application/json">>
            }, json:encode(#{<<"error">> => <<"Failed to create role">>}), Req2),
            {false, Req3, State}
    end.