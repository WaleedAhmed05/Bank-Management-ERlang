% -module(money).
% -export([start/0]).
% start() -> io:fwrite("hello, world\n").

-module(money).
-export([start/1]).

start(Args) ->
    CustomerFile = lists:nth(1, Args),
    BankFile = lists:nth(2, Args),
    {ok, CustomerInfo} = file:consult(CustomerFile),
    {ok, BankInfo} = file:consult(BankFile).



    %print_tuple(CustomerInfo).
    % io:format("Type of Variable: ~p~n", [CustomerInfo]).
    %start_new_process().
    startX(CustomerInfo).


    startX(Tuples) ->
        PidList = spawn_processes(Tuples, []),
        io:format("Process Pids: ~p~n", [PidList]).
    
    spawn_processes([], PidList) ->
        lists:reverse(PidList);
    spawn_processes([{Value1, Value2} | Rest], PidList) ->
        Pid = spawn(fun() -> process_tuple(Value1, Value2) end),
        spawn_processes(Rest, [Pid | PidList]).
    
    process_tuple(Value1, Value2) ->
        % Perform some processing with the tuple values
        io:format("Processing tuple: ~p, ~p~n", [Value1, Value2]).


%To print file content.
% print_tuples([]) ->  % Base case: empty list
%     ok;
% print_tuples([Tuple | Tuples]) ->
%     print_tuple(Tuple),
%     print_tuples(Tuples).

% print_tuple(Tuple) ->
%     io:format("~p~n", [Tuple]).

