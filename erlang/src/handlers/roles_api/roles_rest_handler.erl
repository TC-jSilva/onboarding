-module(roles_rest_handler).
-behaviour(cowboy_handler).

-export([init/2]).

-include_lib("erlang/include/records.hrl").

init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Path = cowboy_req:path(Req0),
    handle_request(Method, Path, Req0, State).

handle_request(<<"GET">>, <<"/staff/roles/", Id/binary>>, Req0, State) ->
    case binary_to_integer(Id) of
        RoleId when is_integer(RoleId) ->
            case roles_store:get_role(RoleId) of
                {ok, Role} ->
                    Response = role_json:roles_to_json([{RoleId, Role}]),
                    Req = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Response, Req0),
                    {ok, Req, State};
                {error, not_found} ->
                    Req = cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>},
                        json:encode(#{<<"error">> => <<"Role not found">>}), Req0),
                    {ok, Req, State};
                {error, Reason} ->
                    Req = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>},
                        json:encode(#{<<"error">> => Reason}), Req0),
                    {ok, Req, State}
            end;
        _ ->
            Req = cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>},
                json:encode(#{<<"error">> => <<"Invalid role ID">>}), Req0),
            {ok, Req, State}
    end;

handle_request(<<"DELETE">>, <<"/staff/roles/", Id/binary>>, Req0, State) ->
    case binary_to_integer(Id) of
        RoleId when is_integer(RoleId) ->
            case roles_store:delete_role(RoleId) of
                ok ->
                    Req = cowboy_req:reply(204, Req0),
                    {ok, Req, State};
                {error, not_found} ->
                    Req = cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>},
                        json:encode(#{<<"error">> => <<"Role not found">>}), Req0),
                    {ok, Req, State};
                {error, Reason} ->
                    Req = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>},
                        json:encode(#{<<"error">> => Reason}), Req0),
                    {ok, Req, State}
            end;
        _ ->
            Req = cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>},
                json:encode(#{<<"error">> => <<"Invalid role ID">>}), Req0),
            {ok, Req, State}
    end;

handle_request(<<"PUT">>, <<"/staff/roles/", Id/binary>>, Req0, State) ->
    case binary_to_integer(Id) of
        RoleId when is_integer(RoleId) ->
            case cowboy_req:read_body(Req0) of
                {ok, Body, Req1} ->
                    Req = try
                        case role_json:json_to_role(Body) of
                            {ok, Role} ->
                                case roles_store:update_role(RoleId, Role) of
                                    ok ->
                                        cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
                                            json:encode(#{<<"message">> => <<"Role updated successfully">>}), Req1);
                                    {error, not_found} ->
                                        cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>},
                                            json:encode(#{<<"error">> => <<"Role not found">>}), Req1);
                                    {error, Reason} ->
                                        cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>},
                                            json:encode(#{<<"error">> => Reason}), Req1)
                                end;
                            {error, Reason} ->
                                cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>},
                                    json:encode(#{<<"error">> => Reason}), Req1)
                        end
                    catch
                        _:_ ->
                            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>},
                                json:encode(#{<<"error">> => <<"Invalid JSON">>}), Req1)
                    end,
                    {ok, Req, State};
                {error, _} ->
                    Req = cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>},
                        json:encode(#{<<"error">> => <<"Failed to read request body">>}), Req0),
                    {ok, Req, State}
            end;
        _ ->
            Req = cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>},
                json:encode(#{<<"error">> => <<"Invalid role ID">>}), Req0),
            {ok, Req, State}
    end;

handle_request(_, _, Req0, State) ->
    Req = cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>},
        json:encode(#{<<"error">> => <<"Not found">>}), Req0),
    {ok, Req, State}.