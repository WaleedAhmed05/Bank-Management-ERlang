# Concurrent-Customer-Bank-Loan-Managment-System-ERlang
This is a short project to demonstrate the power of ERLang concurrency.<br>
Project- COMP6411 - Comparative Study of Programming Languages @ Concordia University, Montreal.

### Introduction
This project goal is to use ERLang language to show user defined concurrency. <br> Project has two text file, one for customers and other for Banks. Program will read all customers/Banks and create a separate process for each customer/Bank. <br>
Each customer can request a loan of maximum $50 to any random Bank. A bank can accept or reject customer loan request based on it's loan budget. Since, every customer and all banks will be running on their on process, their will be no blocking call.

