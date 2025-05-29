-module(redis_client_tests).

-include_lib("eunit/include/eunit.hrl").

setup() ->
    meck:new(eredis),
    ok.

teardown(_) ->
    meck:unload(eredis),
    ok.

redis_client_test() ->
    {foreach,
     fun setup/0,
     fun teardown/1,
     [
      {"should successfully connect to Redis",
       fun() ->
           % Mock successful connection
           meck:expect(eredis, start_link, fun("redis", 6379) -> {ok, self()} end),
           meck:expect(eredis, q, fun(_, ["PING"]) -> {ok, <<"PONG">>} end),

           % Start the client
           {ok, Pid} = redis_client:start_link(),
           ?assert(is_pid(Pid)),

           % Cleanup
           exit(Pid, normal)
       end},
      {"should retry connection on failure",
       fun() ->
           % Mock failed connection followed by success
           meck:expect(eredis, start_link,
               fun("redis", 6379) ->
                   case get(retry_count) of
                       undefined ->
                           put(retry_count, 1),
                           {error, connection_failed};
                       _ ->
                           {ok, self()}
                   end
               end),
           meck:expect(eredis, q, fun(_, ["PING"]) -> {ok, <<"PONG">>} end),

           % Start the client
           {ok, Pid} = redis_client:start_link(),
           ?assert(is_pid(Pid)),

           % Cleanup
           exit(Pid, normal)
       end},
      {"should stop after max retries",
       fun() ->
           % Mock consistent connection failures
           meck:expect(eredis, start_link, fun("redis", 6379) -> {error, connection_failed} end),

           % Start the client
           {stop, no_connection} = redis_client:start_link()
       end},
      {"should successfully ping Redis",
       fun() ->
           % Mock successful connection
           meck:expect(eredis, start_link, fun("redis", 6379) -> {ok, self()} end),
           meck:expect(eredis, q, fun(_, ["PING"]) -> {ok, <<"PONG">>} end),

           % Start the client
           {ok, Pid} = redis_client:start_link(),

           % Test ping
           {ok, <<"PONG">>} = redis_client:ping(),

           % Cleanup
           exit(Pid, normal)
       end},
      {"should successfully get value from Redis",
       fun() ->
           % Mock successful connection
           meck:expect(eredis, start_link, fun("redis", 6379) -> {ok, self()} end),
           meck:expect(eredis, q, fun(_, ["PING"]) -> {ok, <<"PONG">>} end),
           meck:expect(eredis, q, fun(_, ["GET", "test_key"]) -> {ok, <<"test_value">>} end),

           % Start the client
           {ok, Pid} = redis_client:start_link(),

           % Test get
           {ok, <<"test_value">>} = redis_client:get("test_key"),

           % Cleanup
           exit(Pid, normal)
       end},
      {"should successfully set value in Redis",
       fun() ->
           % Mock successful connection
           meck:expect(eredis, start_link, fun("redis", 6379) -> {ok, self()} end),
           meck:expect(eredis, q, fun(_, ["PING"]) -> {ok, <<"PONG">>} end),
           meck:expect(eredis, q, fun(_, ["SET", "test_key", "test_value"]) -> {ok, <<"OK">>} end),

           % Start the client
           {ok, Pid} = redis_client:start_link(),

           % Test set
           {ok, <<"OK">>} = redis_client:set("test_key", "test_value"),

           % Cleanup
           exit(Pid, normal)
       end},
      {"should successfully delete value from Redis",
       fun() ->
           % Mock successful connection
           meck:expect(eredis, start_link, fun("redis", 6379) -> {ok, self()} end),
           meck:expect(eredis, q, fun(_, ["PING"]) -> {ok, <<"PONG">>} end),
           meck:expect(eredis, q, fun(_, ["DEL", "test_key"]) -> {ok, <<"1">>} end),

           % Start the client
           {ok, Pid} = redis_client:start_link(),

           % Test delete
           {ok, <<"1">>} = redis_client:delete("test_key"),

           % Cleanup
           exit(Pid, normal)
       end},
      {"should handle Redis errors gracefully",
       fun() ->
           % Mock successful connection
           meck:expect(eredis, start_link, fun("redis", 6379) -> {ok, self()} end),
           meck:expect(eredis, q, fun(_, ["PING"]) -> {ok, <<"PONG">>} end),
           meck:expect(eredis, q, fun(_, ["GET", "test_key"]) -> {error, connection_lost} end),

           % Start the client
           {ok, Pid} = redis_client:start_link(),

           % Test error handling
           {error, connection_lost} = redis_client:get("test_key"),

           % Cleanup
           exit(Pid, normal)
       end}
     ]}.
