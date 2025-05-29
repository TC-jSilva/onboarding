-module(erlang_get_handler).
-behaviour(cowboy_handler).

-include_lib("erlang/include/records.hrl").

-export([init/2]).
-export([content_types_provided/2]).
-export([allowed_methods/2]).
-export([to_json/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, to_json}], Req, State}.

to_json(Req, State) ->
    case roles_store:get_all_roles() of
        {ok, Roles} ->
            JsonRoles = role_json:roles_to_json(Roles),
            {JsonRoles, Req, State};
        {error, Reason} ->
            ErrorJson = json:encode(#{error => Reason}),
            Req2 = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>}, ErrorJson, Req),
            {halt, Req2, State}
    end.