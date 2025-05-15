-module(erlang_get_all_handler).

-include("../include/records.hrl").

-export([init/2]).
-export([content_types_provided/2]).
-export([allowed_methods/2]).
-export([to_json/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, to_json}], Req, State}.

allowed_methods(Req, State) ->
    {[<<"GET">>], Req, State}.

to_json(Req, State) ->
    Roles = roles_store:get_all_roles(),
    JsonRoles = role_json:roles_to_json(Roles),
    {JsonRoles, Req, State}.