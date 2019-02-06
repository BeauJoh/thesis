# Introduction

<!-- 
For italic, add one * on either side of the text
For bold, add two * on either side of the text
For bold and italic, add _** on either side of the text
-->

<!-- Introduction to the Introduction -->

Supercomputers are used in computationally intensive tasks and are a critical component in current scientific research.
They are essential in simulations for quantum mechanics, weather forecasting, climate research, oil and gas exploration and molecular modeling.
However the largest supercomputers are requiring huge amounts of electricity to operate -- the Summit, currently number one in the TOP500, requires 8.8 MW to power, which is in the terms of the average Australian home (41 kW) could power 215 homes every hour.
To reduce this large energy footprint supercomputers are becoming increasingly heterogeneous.
At an individual node, there is a trend towards specialised hardware -- known as accelerators -- which can expedite the computation of codes from particular classes of scientific workloads.
The use of accelerators for certain programs offers a shorter time to completion, and less energy expenditure, when compared to a conventional CPU architecture.
The next generation of these systems has been designed to incorporate a greater number of accelerators, and of varying types per node.
For instance, the CAPI and NVLINK technologies included in the latest IBM POWER9 processor offers a high-speed interconnect which allows the rapid movement data between processor and accelerator --  where NVIDIA Graphical Processing Unit (GPU) use NVLink, whereas other accelerator devices such as Altera Field-Programmable Gate Array (FPGA), Digital Signal Processors (DSPs), Intel Many-Integrated-Core (MIC) devices, and both Intel and AMD Central Processing Unit (CPU) and AMD GPU devices can utilise the CAPI interconnect.
The support from hardware vendors for a greater mix of heterogeneous devices indicates this is the new direction of supercomputing.
However, this development is recent, and as such the scheduling of workloads to the most suitable accelerator is a new problem.
The cost of exascale computing and their corresponding energy efficiency will be prohibitive without significant improvements in effectively using accelerators on the emerging generation of supercomputers.


This thesis will argue that the characteristics of a scientific code, specifically around computation, memory, branching and parallelism, are independent of any particular device on which they may be finally executed.
The metrics used to quantify each of these characteristics can be collected during program execution on a simulator.
In other words, provided they are collected over a representative workload, a graph traversal program maintains the characteristics of a graph traversal program regardless of problem size or on what platform it is run.
Moreover, these metrics can be used to accurately predict the execution time on each accelerator in a heterogeneous system.


This thesis also presents a methodology to perform runtime predictions for any given code -- provided the feature metrics are pre-generated -- for any accelerator device.
A benchmark suite is extended, a characterisation tool developed, and a model is generated to achieve the task.
We believe this research will be of benefit to the scheduling of codes to the most appropriate device to achieve better performance and utilization on the next-generation of supercomputers.


<!-- Context -- a brief on how the proposed solution works -->

##Context

Accelerators can be programmed in a variety of different languages -- CUDA for Nvidia CPUs, ROCm for AMD devices, OpenMP on Intel CPUs and the MIC.
The Open Compute Language (OpenCL) allows programs to be written once and run anywhere on a range of accelerators.
A majority of accelerator vendors ship products with an OpenCL supported runtime, many of which will be components on the next-generation of supercomputing nodes.
Programs in the OpenCL setting are structured into two partitions, the host and the accelerator/device side.
The developer is responsible for allocating and transferring memory between the host and device.
This requires programs to be structured with computationally intensive regions of code -- known as kernels -- to be identified and written in the OpenCL C kernel language.
Kernels are viewed as indivisible functions, and as such, the nature of these kernels is fixed for all executions, specifically, a kernel does not suffer from the phase-transitions that are common when looking at larger scientific codes.
The composition of all kernels forms an accelerator agnostic implementation for full scientific applications.


A benefit of the fixed/static nature of OpenCL kernels is that the collection of the characteristics is also constant.
Instrumentation of the execution of a kernel measures computation, memory, branching and parallelism metrics -- these form the characteristics of a program and are largely unchanged between run and are independent of data set.
To this end, we developed the Architecture Independent Workload Characterisation (AIWC) tool.
This tool collects 40+ metrics that indicate computation, memory, branching and parallelism characteristics on a per kernel basis.
It simulates an OpenCL device using the Oclgrind tool and the AIWC plugin analyses the program trace, memory locations accessed, and thread-states to generate the metrics.
Metrics can be collected quickly since it is a multi-threaded simulator.
AIWC features, are generated for each kernel invocation and can be embedded as a comment into the header of OpenCL kernel codes -- either in plain-text source or in the SPIR format.


Separately, additional work in this thesis comprises of the extension of the OpenDwarfs benchmark suite.
This was needed since programs that are representative of scientific High Performance Computing (HPC) applications which are capable of execution over a wide range of accelerators are few and far between, specifically with portable performance and reproducible results.
Additionally, until this work was undertaken, the available OpenCL benchmark suites were not rich enough to adequately characterise performance across the diverse range of applications or accelerator devices of interest.
Thus this thesis presents an enhanced version of the OpenDwarfs OpenCL benchmark suite -- denoted the Extended OpenDwarfs Benchmark Suite (EOD) -- which was developed with a strong focus placed on the robustness of applications, the curation of additional benchmarks with an increased emphasis on correctness of results and the selection of 4 problem sizes.


LibSciBench was added to EOD, this includes high precision timers along with support for the collection of PAPI -- hardware performance counters -- events and energy usage information.
Runtime, or elapsed execution times, of all EOD benchmarks, were collected on 15 unique accelerator devices suitable for current HPC systems.
Collection of these times occurs at a per kernel level along with instrumentation of other events common to the OpenCL setting, such as memory setup and timing data movement to accelerator devices.
In addition to the higher level, total elapsed application execution time was also collected.

The final major contribution of this thesis is the development and use of a predictive model, using the random forest algorithm -- a supervised learning algorithm and powerful pattern recognition technique -- to show the link between AIWC features and execution times over all devices.
Thus, the AIWC tool was run and the features collected from all the kernels of EOD.
These AIWC metrics were used as predictor variables into the random forest, and the time data of kernels from the experimental methodology was used as the response variables to indicate predictions.
The accelerators examined in these predictions range from CPU, GPU and MIC, however, the methodology finally presented is expected to perform over DSP and FPGA also.


The final random forest model performs well and is capable of highly accurate predictions which on average differ from the measured experimental run-times by 1.1%, which correspond to actual execution time mispredictions of 8 $\mu s$ to 1 secs according to problem size.
The model is capable of predicting execution times for specific devices based on the computational characteristics captured by the AIWC tool, which in turn, provides a good prediction of an accelerator devices execution time needed for a real-world scheduler for nodes of future super-computing systems.

<!-- Restatement of the problem -->
<!-- Problems in heterogeneous supercomputing -->
## Restatement of the problem

The future of supercomputing comprises several heterogeneous devices at the node level.
The POWER9 is featured in the latest Summit and forthcoming Sierra supercomputers, and is configured such with two GPUs per CPU.
High bandwidth, low latency interconnects such as the Cray XC50 *Aries*, Fujitsu Post-K *Tofu* and IBM POWER9 *Bluelink*, support tighter integration between compute devices on a node.
This facilitates the usage of a mix of accelerators given the low penalty to move data between them.
Evaluating the suitability of any given device on a node requires a comprehensive benchmark suite which is capable of efficiently executing on all devices in a hardware agnostic way.
Unfortunately, current benchmark suites are ill-suited to the task, either consisting of several different implementations per each device or lacking a comprehensive range of scientific applications to fully explore the performance characteristics of the device.
Further, this suitability can be concerned with energy consumption, which is critical to the proposed exascale systems envisaged in the future, making performance-per-watt a fundamental concern.
Additionally, examining the computation characteristics of scientific workloads is difficult, and this complexity only increases when considering the wide range of hardware in heterogeneous supercomputing -- and the corresponding different implementations per device.
Both the difficulties in identifying characteristics of scientific hardware agnostic codes, and the wider diversity of devices of the next-generation of HPC systems further compounds the issue of scheduling code within a node in order to fully utilise supercomputing facilities.


<!-- Restatement of the response -->
##Thesis Contributions

A benchmark suite is extended to include a greater range of scientific applications and over a differing problem sizes.
Additionally, the extended suite incorporates a high precision timing library which is capable of measuring energy usage and execution times on any OpenCL device.
Examining the performance of the benchmark suite over a range of devices allows a direct evaluation to be made between these devices on a per application basis.
From this evaluation, the suitably of OpenCL as a hardware agnostic language is shown.


Separately, the Architecture Independent Workload Characterisation (AIWC) tool is presented and is shown to be capable of analysing kernels and extract a set of predefined features or characteristics.
The benefits of AIWC include that it:

1) provides insights around the inclusion of an application via diversity analysis of the feature-space.
2) measures requirements in terms of FLOPs, memory movement and integer ops of any application kernel -- which allows the automatic calculation of theoretical peak performance for a given device.
3) can be used to examine the phase-transitional properties of application codes -- for instance if the instruction mix changes over time in terms of the balance between floating-point and memory operations.
The tool can be used in diversity analysis -- which is essential when assembling benchmark suites and justifying the inclusion of an application.
Furthermore, these metrics are used for creating the prediction model to evaluate the performance of OpenCL kernels on different hardware devices and settings.
Such a model is then applied as a prognosis tool to predict the performance of an application for any given platform without additional instrumentation.
This prediction adds information that can be incorporated into existing HPC schedulers and has no run-time overhead -- codes are examined one time by the developer when instrumenting with AIWC and these, in turn, are embedded into the header of each kernel code to be evaluated by the predictive model at the time of scheduling.


<!-- Roadmap -->

##Thesis Structure

Chapter 2 canvasses the existing literature and current techniques used to schedule heterogeneous resources.
Chapter 3 discusses the extensions added to the OpenDwarfs Benchmarking Suite in EOD.
Chapter 4 highlights the construction, design decisions made and usage of the AIWC tool.
Chapter 5 develops the prediction model and examines the accuracy of the final predictions.
Chapter 6 discusses conclusions of this thesis and the future work required for the predictive model to be incorporated into scheduling on future supercomputing systems.

