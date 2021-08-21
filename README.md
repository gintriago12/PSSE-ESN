# PSSE-ESN
This repository provides a MATLAB script that connects [Echo State Networks](http://www.scholarpedia.org/article/Echo_state_network) (ESN) and power systems state estimation (PSSE). The architecture of an ESN consists of three parts: input, reservoir, and output. The input induces nonlinear signals in the reservoir's neurons. The output is a result of a linear combination of such signals. The PSSE problem statement is as follows: given a set of noisy measurements (active and reactive power flows, active and reactive power injections), we estimate voltage magnitudes and angles for all system buses. The equations modeling the relation between measurements and voltage are highly nonlinear. Typically, PSSE is studied under different scenarios. The scenarios that we considered are normal operation and sudden load change.
This repository contains part of the code of the article Data-Driven State Estimation for Power Systems using Echo State Networks submitted (waiting for acceptance/rejection notification) to IEEE SmartGridComm Conference 2021.

## Dataset
For each scenario, there exists a .mat file that contains two arrays: input and output. The input array contains the noisy measurements, and the output array has the true measurements. An IEEE 14-bus test case is used to obtain the data. The data description for both scenarios can be found [here](https://drive.google.com/drive/folders/1wKpF2FwFHSne97nx7XcSvXXCvuPmQ1g5?usp=sharing). Refer to section III of the PDF file.

## Motivation
In this repository, we want to provide researchers in power systems and recurrent neural networks to explore the capabilities of the ESN's nonlinear reservoir of neurons to model the power flow highly nonlinear equations.
