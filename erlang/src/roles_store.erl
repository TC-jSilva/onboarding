-module(roles_store).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([insert_role/1, get_all_roles/0, delete_role/1, update_role/2, get_role/1]).

-include("../include/records.hrl").

-record(state, {}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, #state{}}.

handle_call({get_all_roles}, _From, State) ->
    case redis_client:get("roles:keys") of
        {ok, undefined} ->
            {reply, {ok, []}, State};
        {ok, Keys} ->
            KeyList = binary:split(Keys, <<",">>, [global]),
            Roles = lists:filtermap(fun(Key) ->
                case redis_client:get(Key) of
                    {ok, undefined} ->
                        false;
                    {ok, RoleBin} ->
                        try
                            Role = binary_to_term(RoleBin),
                            [_, IdBin] = binary:split(Key, <<":">>),
                            Id = binary_to_integer(IdBin),
                            {true, {Id, Role}}
                        catch
                            _:_ ->
                                io:format("Error parsing role data for key: ~p~n", [Key]),
                                false
                        end;
                    {error, Reason} ->
                        io:format("Error getting role: ~p~n", [Reason]),
                        false
                end
            end, KeyList),
            {reply, {ok, Roles}, State};
        {error, Reason} ->
            io:format("Error getting keys: ~p~n", [Reason]),
            {reply, {error, Reason}, State}
    end;

handle_call({insert_role, Role}, _From, State) ->
    % Generate a unique ID for the new role
    Id = integer_to_binary(erlang:system_time(microsecond)),
    RoleKey = <<"role:", Id/binary>>,

    % Store the role data
    case redis_client:set(RoleKey, term_to_binary(Role)) of
        {ok, <<"OK">>} ->
            % Update the keys list
            case redis_client:get("roles:keys") of
                {ok, undefined} ->
                    % First role being added
                    case redis_client:set("roles:keys", RoleKey) of
                        {ok, <<"OK">>} ->
                            {reply, {ok, Id}, State};
                        {error, Reason} ->
                            io:format("Error updating keys list: ~p~n", [Reason]),
                            {reply, {error, Reason}, State}
                    end;
                {ok, ExistingKeys} ->
                    % Append to existing keys
                    NewKeys = <<ExistingKeys/binary, ",", RoleKey/binary>>,
                    case redis_client:set("roles:keys", NewKeys) of
                        {ok, <<"OK">>} ->
                            {reply, {ok, Id}, State};
                        {error, Reason} ->
                            io:format("Error updating keys list: ~p~n", [Reason]),
                            {reply, {error, Reason}, State}
                    end;
                {error, Reason} ->
                    io:format("Error getting keys list: ~p~n", [Reason]),
                    {reply, {error, Reason}, State}
            end;
        {error, Reason} ->
            io:format("Error storing role: ~p~n", [Reason]),
            {reply, {error, Reason}, State}
    end;

handle_call(_Msg, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

% Public API
insert_role(Role) ->
    gen_server:call(?MODULE, {insert_role, Role}).

get_all_roles() ->
    gen_server:call(?MODULE, {get_all_roles}).

delete_role(Id) ->
    gen_server:call(?MODULE, {delete_role, Id}).

update_role(Id, Role) ->
    gen_server:call(?MODULE, {update_role, Id, Role}).

get_role(Id) ->
    gen_server:call(?MODULE, {get_role, Id}).