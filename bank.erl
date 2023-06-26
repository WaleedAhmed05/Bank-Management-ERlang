%% @author WaleedAhmed05
%% Version 1.0


-module(bank).

-import(timer,[sleep/1]).
-import(money,[master_receiver/0]).

-export([bank_receiver/2]).
-export([bankApp/2]).

%start function simple start Bank receiver.
bankApp(Bank_name, Bank_amountX) ->
	bank_receiver(Bank_name,Bank_amountX).


% connectMoney(Para1, Para2, Para3) ->
% 	receive
% 	{Para1, Para2} ->
% 		IsConnected  = true
% 	end

bank_receiver(Bank_name,Bank_amountX) ->
	receive
		{Name,Famount,Tamount, Curr_amount,Bank_keys} -> 
			Balance = Bank_amountX - Curr_amount,

			if 
				Balance >= 0 andalso Curr_amount > 0 ->
					whereis(money) ! {accept_req,Name,Bank_name,Famount,Tamount, Curr_amount,Bank_keys},
					Bank_amount2 = Balance;
			true ->
					whereis(money) ! {reject,Name,Bank_name,Famount,Tamount, Curr_amount,Bank_keys},
					Bank_amount2 = Bank_amountX
			end,
			bank_receiver(Bank_name,Bank_amount2);
		
		{req_balance, Banknamem} ->
			whereis(money) ! {check_balance, Banknamem, Bank_amountX}, 
			bank_receiver(Bank_name,Bank_amountX)
			
	end.


