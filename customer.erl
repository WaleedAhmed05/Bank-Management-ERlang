%% @author WaleedAhmed05
%% Version 1.0

-module(customer).
-import(lists,[nth/2]).
-import(lists,[delete/2]).
-import(timer,[sleep/1]).
-import(money,[requestreceive/0]).
-import(bank,[bank_receiver/2]).

-export([customerApp/3]).
-export([customer_actionX/6]).
-export([customer_receiver/1]).



customerApp(Name, Amount, Bank_keys) ->

	Length = length(Bank_keys),
	customer_actionX(Length,Name,Amount,Amount,Amount,Bank_keys),
	customer_receiver(Name).

%Customer receiver
customer_receiver(Name) ->

				receive
					{accept_req, Name, Bank_name, Fin_amount,Tot_amount, Amount,Keysb} -> 
							updateXcustomer(true,Name,Bank_name,Fin_amount,Tot_amount, Amount,Keysb),
							customer_receiver(Name);
					{reject, Name, Bank_name,Fin_amount, Tot_amount, Amount,Keysb} -> 
							updateXcustomer(false,Name,Bank_name,Fin_amount,Tot_amount, Amount,Keysb),
							customer_receiver(Name)
				end.

customer_actionX(Max_length,Name,Fin_amount,Tot_amount, Amount,Bank_keys) ->
					Customer_amount = Amount,
					random:seed(now()),
					RandX = rand:uniform(100),
					if RandX > 10 ->
						timer:sleep(rand:uniform(RandX));
					true ->
						timer:sleep(10)
					end,
					if 
						Customer_amount > 50 ->
							Rand_XX =  rand:uniform(50);
						true ->
							Rand_XX =  rand:uniform(Customer_amount)
					end,
					
					Bankcalled = nth(rand:uniform(Max_length),Bank_keys),
					Bankpid = whereis(Bankcalled),
					whereis(money) ! {request,Name,Rand_XX,Bankcalled},
					Bankpid ! {Name, Fin_amount,Tot_amount, Rand_XX, Bank_keys}.


updateXcustomer(IsAccepted,Name,Bank_name,Fin_amount,Tot_amount,Amount,Keysb) ->
	if
		IsAccepted == true ->
			Customer_amount = Tot_amount - Amount,
			Bank_keys_B= Keysb,
			Length = length(Bank_keys_B);	
		true ->
			Customer_amount = Tot_amount,
			Bank_keys_B = delete(Bank_name,Keysb),
			Length = length(Bank_keys_B),
			io:fwrite("")
	end,
	if Length == 0 andalso IsAccepted == false ->
		 Amtleft = Fin_amount - Tot_amount,
		whereis(money) ! {remLeftX,Name,Amtleft};   
	true ->
		io:fwrite("")
	end,
	if Customer_amount == 0 ->
		 whereis(money) ! {reached,Name,Fin_amount};
	true ->
		io:fwrite("")
	end,
	if
		Customer_amount > 0 andalso Length /= 0 ->
			Rand_length =  rand:uniform(Length),
			customer_actionX(Rand_length,Name,Fin_amount,Customer_amount,Customer_amount,Bank_keys_B);
		true ->
			io:fwrite("")
	end.



		
	