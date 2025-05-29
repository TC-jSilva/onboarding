-module(redis_client).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([get_client/0, ping/0, get/1, set/2, delete/1]).

-record(state, {client, retry_count = 0, max_retries = 5}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("Starting Redis connection...~n"),
    connect_to_redis(#state{}).

connect_to_redis(State) ->
    try
        {ok, Client} = eredis:start_link("redis", 6379),
        io:format("Redis client initialized: ~p~n", [Client]),
        % Test the connection
        case eredis:q(Client, ["PING"]) of
            {ok, <<"PONG">>} ->
                io:format("Redis connection successful~n"),
                {ok, #state{client = Client}};
            {error, PingReason} ->
                io:format("Redis PING failed: ~p~n", [PingReason]),
                handle_connection_error(State)
        end
    catch
        Type:Error ->
            io:format("Redis connection error: ~p:~p~n", [Type, Error]),
            handle_connection_error(State)
    end.

handle_connection_error(#state{retry_count = Count, max_retries = Max} = State) ->
    case Count < Max of
        true ->
            io:format("Retrying Redis connection (attempt ~p/~p)...~n", [Count + 1, Max]),
            timer:sleep(1000), % Wait 1 second before retrying
            connect_to_redis(State#state{retry_count = Count + 1});
        false ->
            io:format("Max retries reached, giving up~n"),
            {stop, no_connection}
    end.

handle_call(get_client, _From, State) ->
    {reply, State#state.client, State};

handle_call({ping}, _From, State) ->
    Result = eredis:q(State#state.client, ["PING"]),
    {reply, Result, State};

handle_call({get, Key}, _From, State) ->
    Result = eredis:q(State#state.client, ["GET", Key]),
    {reply, Result, State};

handle_call({set, Key, Value}, _From, State) ->
    Result = eredis:q(State#state.client, ["SET", Key, Value]),
    {reply, Result, State};

handle_call({delete, Key}, _From, State) ->
    Result = eredis:q(State#state.client, ["DEL", Key]),
    {reply, Result, State};

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    io:format("Terminating Redis connection...~n"),
    eredis:stop(State#state.client),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

% Public API
get_client() ->
    gen_server:call(?MODULE, get_client).

ping() ->
    gen_server:call(?MODULE, ping).

get(Key) ->
    gen_server:call(?MODULE, {get, Key}).

set(Key, Value) ->
    gen_server:call(?MODULE, {set, Key, Value}).

delete(Key) ->
    gen_server:call(?MODULE, {delete, Key}).