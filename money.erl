%% @author WaleedAhmed05
%% Version 1.0

-module(money).
-import(customer,[customerApp/3]).
-import(bank,[bankApp/2]).
-import(maps, [get/2]).
-import(lists,[nth/2]).
-import(lists,[append/2]).
-import(maps, [remove/2]).  
-import(maps, [put/3]).

-export([start/1]).


start(Args) ->
	CustomerFile = lists:nth(1, Args),
	BankFile = lists:nth(2, Args),
	register(money, self()),

	io:fwrite("** The financial market is opening for the day **~n ~n"),
	Log_msg = "Starting transaction log...~n~n",
	io:fwrite(Log_msg),

	%Banks Processing
	{ok,BankInfo} = file:consult(BankFile),
	Banks_mapX = maps:from_list(BankInfo),
	Banks_map_keys = maps:keys(Banks_mapX),
	Banks_length = length(Banks_map_keys),

	customer_bank_action(Banks_length,Banks_map_keys, Banks_mapX,false,Banks_map_keys),

	%Customer Processing
	{ok,CustomerInfo} = file:consult(CustomerFile),
	Customer_mapX = maps:from_list(CustomerInfo),
	Customer_map_keys = maps:keys(Customer_mapX),
	Customer_length = length(Customer_map_keys),
	Final_banks_rpt=[],
	
	Total_bank_amount=calculate_total_loaned(BankInfo), %this will store total bank balance of all banks.
		
	customer_bank_action(Customer_length, Customer_map_keys,Customer_mapX,true,Banks_map_keys),
	Meta_data=[CustomerFile,BankFile,Total_bank_amount], 
	master_receiver(Banks_map_keys,Customer_length, Customer_mapX,Customer_mapX,Banks_length,Final_banks_rpt,Meta_data).


customer_bank_action(0,_,_,_,_) ->	%Base case to stop recursion.
	ok; 

customer_bank_action(Max_length, Map_keys , Map, IsCustomer,Bank_keys) when Max_length > 0 ->
	Name = nth(Max_length,Map_keys),
	Amt = get(Name, Map),
	
	if %Check if the function calls for a customer or a Bank?
		IsCustomer == true -> 
			Pid = spawn(customer, customerApp, [Name, Amt,Bank_keys]), %Create a process for each customer.
			register(Name,Pid);
		true ->
			Pid = spawn(bank, bankApp, [Name, Amt]),  %Create a process for each Bank.
			register(Name,Pid)
	end,

	customer_bank_action(Max_length-1, Map_keys,Map,IsCustomer,Bank_keys).

%This function will check bank balance.
request_Bank_balance(Bank_keys) -> 	

		Length = length(Bank_keys),
		bank_balance(Length,Bank_keys).

bank_balance(0,_) ->		%Base case to stop recursion
	ok;

bank_balance(Length,Bank_keys) when Length > 0 ->

	Bank_name = nth(Length,Bank_keys),
	whereis(Bank_name) ! {req_balance, Bank_name},
	bank_balance(Length-1,Bank_keys).
	

	
%This function will Customers report.
generateCustomerReport(TupleList,Meta_data) ->

	Total_remaining=calculate_total_loaned(TupleList),
	Total_original_amount=lists:nth(3,Meta_data),
	Total_loaned=Total_original_amount-Total_remaining,

	BankFileX = lists:nth(2, Meta_data),
	{ok,BankInfoX} = file:consult(BankFileX),
	Bank_map = maps:from_list(BankInfoX),

	io:format("~nBanks:~n"),
	lists:foreach(fun({Bank_name, Rem_balance}) ->
		Org_balance = maps:get(Bank_name, Bank_map),
		io:format("	~p: original ~p, Balance ~p~n", [Bank_name,Org_balance,Rem_balance])
  end, TupleList),

  	io:format("	----~n"),
    io:format("	Total: original ~p, loaned ~p~n",[Total_original_amount, Total_loaned]).	


customer_action(_,0,_,_,_) ->			%Base case to stop recursion
	ok;

customer_action(Keys,Lent,Map,Meta_data,Customer_length) when Lent >0 ->
	Name = nth(Lent, Keys),
	Tamt = get(Name,Map),

	CustFileX = lists:nth(1, Meta_data),
	{ok,CustInfoX} = file:consult(CustFileX),
	Cust_map = maps:from_list(CustInfoX),
	Org_balance = maps:get(Name, Cust_map),

	io:fwrite("	~p: objective ~p, received ~p~n",[Name,Org_balance,Tamt]),

	customer_action(Keys,Lent-1,Map,Meta_data,Customer_length-1).

print_customer(Map1,Map2,Meta_data,Customer_length) ->

	Keys1 = maps:keys(Map1),
	Lent1 = length(Keys1),
	io:fwrite("~n~n"),
	io:fwrite("Customers:~n"),
	customer_action(Keys1,Lent1,Map1,Meta_data,Customer_length),
	Keys2 = maps:keys(Map2),
	Lent2 = length(Keys2),
	customer_action(Keys2,Lent2,Map2,Meta_data,Customer_length).
	

%This function will generate Banks report.
generateBankReport(TupleList,Meta_data) ->

	Total_remaining=calculate_total_loaned(TupleList),
	Total_original_amount=lists:nth(3,Meta_data),
	Total_loaned=Total_original_amount-Total_remaining,

	BankFileX = lists:nth(2, Meta_data),
	{ok,BankInfoX} = file:consult(BankFileX),
	Bank_map = maps:from_list(BankInfoX),

	io:format("~nBanks:~n"),
	lists:foreach(fun({Bank_name, Rem_balance}) ->
		Org_balance = maps:get(Bank_name, Bank_map),
		io:format("	~p: original ~p, Balance ~p~n", [Bank_name,Org_balance,Rem_balance])
  end, TupleList),

  	io:format("	----~n"),
    io:format("	Total: original ~p, loaned ~p~n~n~n",[Total_original_amount, Total_loaned]),
	io:format("The financial market is closing for the day...").
	


master_receiver(M2keys,Customer_length,Mwohoo,Mbohoo,Banks_length,Final_banks_rpt,Meta_data) ->

			receive
				{accept_req,Name,Bname,Famount,Tamount, Amt,Bkeys} -> %if banks approves
					
					io:fwrite("$ The ~p bank approves a loan of ~p dollar(s) to ~p ~n", [Bname,Amt,Name]),
					whereis(Name) ! {accept_req,Name,Bname,Famount,Tamount, Amt,Bkeys},
					master_receiver(M2keys,Customer_length,Mwohoo,Mbohoo,Banks_length,Final_banks_rpt,Meta_data);

				{reject,Name,Bname,Famount,Tamount, Amt,Bkeys} -> %if bank denies
					io:fwrite("$ The ~p bank denies a loan of ~p dollar(s) to ~p~n", [Bname,Amt,Name]),
					whereis(Name) ! {reject,Name,Bname,Famount,Tamount, Amt,Bkeys},
					master_receiver(M2keys,Customer_length,Mwohoo,Mbohoo,Banks_length,Final_banks_rpt,Meta_data);

				{reached,Name,Tamt} ->
					M2 = Mwohoo,
					M3 = Mbohoo,
					M4 = remove(Name,M2),
					M5 = remove(Name,M3),
					M6 = put(Name,Tamt,M4),
					unregister(Name),
					Len =  Customer_length - 1,
					if Len == 0 ->
						print_customer(M6,M5,Meta_data,Customer_length),
						   request_Bank_balance(M2keys);
					   true ->
						   io:fwrite("")
					end,
					master_receiver(M2keys,Len,M6,M5,Banks_length,Final_banks_rpt,Meta_data);

				{remLeftX,Name,Amount} ->
					M2 = Mwohoo,
					M3 = Mbohoo,
					M4 = remove(Name,M2),
					M5 = remove(Name,M3),
					M6 = put(Name,Amount,M5),
					unregister(Name),
					Len =  Customer_length - 1,
					if Len == 0 ->
						   print_customer(M4,M6,Meta_data,Customer_length),
						   request_Bank_balance(M2keys);
					   true ->
						   io:fwrite("")
					end,
					master_receiver(M2keys,Len,M4,M6,Banks_length,Final_banks_rpt,Meta_data);

				{request,Name,A,Bank} ->
					io:fwrite("? ~p requests a loan of ~p dollar(s) from the ~p bank~n",[Name,A,Bank]),
					master_receiver(M2keys,Customer_length,Mwohoo,Mbohoo,Banks_length,Final_banks_rpt,Meta_data);

				{check_balance, Name, Amount} ->
					%io:fwrite("~p: original $$$, balance ~p~n",[Name,Amount]),
					Banq=[{Name,Amount}],
					if Banks_length == 1 -> 
						generateBankReport(append(Final_banks_rpt,Banq),Meta_data); 
					 true -> 
						% Temp=1+1
						io:fwrite("")
				  end,
					master_receiver(M2keys,Customer_length,Mwohoo,Mbohoo,Banks_length-1,
					append(Final_banks_rpt,Banq),Meta_data)
					
				after 5000 -> 
					io:fwrite("")
					
			end.
		


%Supporting Functions.
calculate_total_loaned(List) ->
		lists:foldl(fun({_, Amount}, Acc) -> Amount + Acc end, 0, List).
	

