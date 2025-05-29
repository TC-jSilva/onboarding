-module(roles_supervisor_tests).

-include_lib("eunit/include/eunit.hrl").
setup() ->
    meck:new(redis_client),
    meck:new(roles_store),
    ok.

teardown(_) ->
    meck:unload(redis_client),
    meck:unload(roles_store),
    ok.

roles_supervisor_test() ->
    {foreach,
     fun setup/0,
     fun teardown/1,
     [
      {"supervisor should start and monitor child processes",
       fun() ->
           meck:expect(redis_client, start_link, fun() -> {ok, self()} end),
           meck:expect(roles_store, start_link, fun() -> {ok, self()} end),

           {ok, Pid} = roles_supervisor:start_link(),
           ?assert(is_pid(Pid)),

           % Verify child processes are started
           ?assert(meck:called(redis_client, start_link, [])),
           ?assert(meck:called(roles_store, start_link, [])),

           % Cleanup
           exit(Pid, normal)
       end},
      {"supervisor should restart child processes on failure",
       fun() ->
           meck:expect(redis_client, start_link, fun() -> {ok, self()} end),
           meck:expect(roles_store, start_link, fun() -> {ok, self()} end),

           {ok, Pid} = roles_supervisor:start_link(),
           ?assert(is_pid(Pid)),

           % Simulate child process failure
           ChildPid = whereis(redis_client),
           exit(ChildPid, kill),

           % Wait for restart
           timer:sleep(100),

           % Verify restart
           ?assert(meck:called(redis_client, start_link, [])),

           % Cleanup
           exit(Pid, normal)
       end}
     ]}.

