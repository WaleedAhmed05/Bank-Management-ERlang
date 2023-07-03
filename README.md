## Concurrent-Customer-Bank-Loan-Managment-System-ERlang
This is a short project to demonstrate the power of ERLang concurrency.<br>
Project- COMP6411 - Comparative Study of Programming Languages @ Concordia University, Montreal.

### Introduction
This project goal is to use ERLang language to utilize user defined concurrency. <br> Project has two text file, one for customers and other for Banks. Program will read all customers/Banks and create a separate process for each customer/Bank. <br>
Each customer can request a loan of maximum $50 to any random Bank. A bank can accept or reject customer loan request based on it's loan budget. Since, every customer and all banks will be running on their on process, their will be no blocking call.

### Requirements or Prerequisites
Download [Erlang/OTP](https://www.erlang.org/downloads). <br>
Download and install any editor [Notepad++](https://notepad-plus-plus.org/downloads/) or [Visual_Studio_Code](https://code.visualstudio.com/) <br>
Set ERlang Path variable. <br>

### Input files.
customer.txt / "c1.txt" files contains all list of customer who wants to request loan. <br>
bank.txt / "b1.txt" files contains all list of banks. <br>

### How to run Project?
Download project, and make sure bank.txt , customer.txt, bank.erl, customer.erl & money.erl are in same directory. <br>
compile money.erl , bank.erl & customer.erl file to create beam file.
```
erlc money.erl
```
```
erlc bank.erl
```
```
erlc customer.erl
```
Once, all three beam files created, run this command to execute project.
```
erl -noshell -run money start customer_file_name.txt bank_file_name.txt -s init stop
```