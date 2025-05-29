-module(erlang_post_handler).
-behaviour(cowboy_handler).

-include_lib("erlang/include/records.hrl").

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
            case roles_store:insert_role(Role) of
                {ok, Id} ->
                    Req3 = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>},
                        json:encode(#{id => Id, message => <<"Role created successfully">>}), Req2),
                    {ok, Req3, State};
                {error, Reason} ->
                    Req3 = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>},
                        json:encode(#{error => Reason}), Req2),
                    {ok, Req3, State}
            end;
        {error, Reason} ->
            Req3 = cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>},
                json:encode(#{error => Reason}), Req2),
            {ok, Req3, State}
    end.