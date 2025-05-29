-module(role_json).

-export([roles_to_json/1, json_to_role/1]).

-include_lib("erlang/include/records.hrl").

%% Convert a single role record to a map
role_to_map({Id, Role}) ->
    Map = #{
        <<"id">> => Id,
        <<"event_type">> => Role#role.event_type,
        <<"data">> => #{
            <<"first_name">> => Role#role.data#data.first_name,
            <<"gender">> => Role#role.data#data.gender,
            <<"last_name">> => Role#role.data#data.last_name,
            <<"mrn">> => Role#role.data#data.mrn,
            <<"organization">> => Role#role.data#data.organization
        }
    },
    Map.

%% Convert a list of role records to JSON
roles_to_json(Roles) when is_list(Roles) ->
    case Roles of
        [] -> json:encode([]);
        _ ->
            JsonRoles = lists:map(fun role_to_map/1, Roles),
            json:encode(JsonRoles)
    end.

%% Convert JSON to a role record
json_to_role(Json) ->
    Map = json:decode(Json),
    Data = maps:get(<<"data">>, Map, #{}),
    Role = #role{
        event_type = maps:get(<<"event_type">>, Map, <<>>),
        data = #data{
            first_name = maps:get(<<"first_name">>, Data, <<>>),
            gender = maps:get(<<"gender">>, Data, <<>>),
            last_name = maps:get(<<"last_name">>, Data, <<>>),
            mrn = maps:get(<<"mrn">>, Data, <<>>),
            organization = maps:get(<<"organization">>, Data, <<>>)
        }
    },
    {ok, Role}.