-module(role_json_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("erlang/include/records.hrl").

role_json_test() ->
    [
     {"should convert empty role list to empty JSON array",
      fun() ->
          Result = role_json:roles_to_json([]),
          ?assertEqual(<<"[]">>, Result)
      end},
     {"should convert single role to JSON",
      fun() ->
          Role = #role{
              event_type = <<"test_event">>,
              data = #data{
                  first_name = <<"John">>,
                  last_name = <<"Doe">>,
                  gender = <<"M">>,
                  mrn = <<"12345">>,
                  organization = <<"Test Org">>
              }
          },
          Roles = [{1, Role}],
          Result = role_json:roles_to_json(Roles),
          Expected = <<"{\"id\":1,\"event_type\":\"test_event\",\"data\":{\"first_name\":\"John\",\"last_name\":\"Doe\",\"gender\":\"M\",\"mrn\":\"12345\",\"organization\":\"Test Org\"}}">>,
          ?assertEqual(Expected, Result)
      end},
     {"should convert multiple roles to JSON array",
      fun() ->
          Role1 = #role{
              event_type = <<"test_event1">>,
              data = #data{
                  first_name = <<"John">>,
                  last_name = <<"Doe">>,
                  gender = <<"M">>,
                  mrn = <<"12345">>,
                  organization = <<"Test Org">>
              }
          },
          Role2 = #role{
              event_type = <<"test_event2">>,
              data = #data{
                  first_name = <<"Jane">>,
                  last_name = <<"Smith">>,
                  gender = <<"F">>,
                  mrn = <<"67890">>,
                  organization = <<"Test Org">>
              }
          },
          Roles = [{1, Role1}, {2, Role2}],
          Result = role_json:roles_to_json(Roles),
          Expected = <<"[{\"id\":1,\"event_type\":\"test_event1\",\"data\":{\"first_name\":\"John\",\"last_name\":\"Doe\",\"gender\":\"M\",\"mrn\":\"12345\",\"organization\":\"Test Org\"}},{\"id\":2,\"event_type\":\"test_event2\",\"data\":{\"first_name\":\"Jane\",\"last_name\":\"Smith\",\"gender\":\"F\",\"mrn\":\"67890\",\"organization\":\"Test Org\"}}]">>,
          ?assertEqual(Expected, Result)
      end},
     {"should convert JSON to role record",
      fun() ->
          Json = <<"{\"event_type\":\"test_event\",\"data\":{\"first_name\":\"John\",\"last_name\":\"Doe\",\"gender\":\"M\",\"mrn\":\"12345\",\"organization\":\"Test Org\"}}">>,
          {ok, Role} = role_json:json_to_role(Json),
          Expected = #role{
              event_type = <<"test_event">>,
              data = #data{
                  first_name = <<"John">>,
                  last_name = <<"Doe">>,
                  gender = <<"M">>,
                  mrn = <<"12345">>,
                  organization = <<"Test Org">>
              }
          },
          ?assertEqual(Expected, Role)
      end},
     {"should handle missing optional fields in JSON",
      fun() ->
          Json = <<"{\"event_type\":\"test_event\",\"data\":{\"first_name\":\"John\"}}">>,
          {ok, Role} = role_json:json_to_role(Json),
          Expected = #role{
              event_type = <<"test_event">>,
              data = #data{
                  first_name = <<"John">>,
                  last_name = <<>>,
                  gender = <<>>,
                  mrn = <<>>,
                  organization = <<>>
              }
          },
          ?assertEqual(Expected, Role)
      end},
     {"should handle empty data object in JSON",
      fun() ->
          Json = <<"{\"event_type\":\"test_event\",\"data\":{}}">>,
          {ok, Role} = role_json:json_to_role(Json),
          Expected = #role{
              event_type = <<"test_event">>,
              data = #data{
                  first_name = <<>>,
                  last_name = <<>>,
                  gender = <<>>,
                  mrn = <<>>,
                  organization = <<>>
              }
          },
          ?assertEqual(Expected, Role)
      end},
     {"should handle missing data field in JSON",
      fun() ->
          Json = <<"{\"event_type\":\"test_event\"}">>,
          {ok, Role} = role_json:json_to_role(Json),
          Expected = #role{
              event_type = <<"test_event">>,
              data = #data{
                  first_name = <<>>,
                  last_name = <<>>,
                  gender = <<>>,
                  mrn = <<>>,
                  organization = <<>>
              }
          },
          ?assertEqual(Expected, Role)
      end}
    ].

