# Introduction

<!-- 
For italic, add one * on either side of the text
For bold, add two * on either side of the text
For bold and italic, add _** on either side of the text
-->

<!-- Introduction to the Introduction -->


Supercomputers are becoming increasingly heterogenous.
At an individual node, there is an increasing trend to use specialised hardware -- known as accelerators -- which can expedite the computation of codes from particular classes of scientific workloads.
The next generation of these systems has been designed to incorporate a greater number of accelerators.
For instance, the CAPI and NVLINK technologies included in the latest IBM POWER9 processor offers a high-speed interconnect which allows the rapid movement data between processor and accelerator -- NVIDIA Graphical Processing Unit (GPU) with NVLINK, and CAPI supporting Altera Field-Programmable Gate Array (FPGA), Intel Central Processing Unit (CPU) co-processors to AMD CPU and GPU devices.
The POWER9 is set to feature in the upcoming Summit and Sierra Supercomputers.
The support from mainframe vendors for a greater mix of heterogenous devices indicates this is the new direction of supercomputing.
However, this development is recent, and as such the scheduling of workloads to the suitable accelerator is a new problem.


Independently, the characteristics of a scientific code, specifically around computation, memory, branching and parallelism, are independent of any particular device on which they may be finally executed.
The metrics used to quantify each of these characteristics can be collected during program execution on a simulator.
In other words, provided they are collected over a representative workload, a graph traversal program maintains the characteristics of a graph traversal program regardless of problem size.
Moreover, these metrics can be used to accurately predict the execution time on each accelerator in a heterogenous system.


This thesis outlines the methodology required to perform runtime predictions for any given code -- provided the feature metrics are pre-generated -- for any accelerator device.
A benchmark suite is extended, a characterisation tool developed, and a model is generated to achieve the task.
This research is of benefit to the scheduling of codes to the most appropriate device which in turn provides essential information for scheduling, to better utilise the next-generation of supercomputers.
Without significant improvements in effectively using accelerators on these future systems, the cost of exascale computing and their corresponding energy efficiency will be prohibitive.


<!-- Context -- a brief on how the proposed solution works -->

##Context


The Open Compute Language (OpenCL) allows programs to be written once and run anywhere on a range of accelerators.
A majority of accelerator vendors ship products with an OpenCL supported runtime, many of which will be components on the next-generation of supercomputing nodes.
Programs in the OpenCL setting are structured into two partitions, the host and the accelerator/device side.
As such, the developer is manually responsible for allocating and transferring memory between the host and device.
This requires programs to be restructured with computationally intensive regions of code -- known as kernels -- to be identified and partitioned -- and rewritten in the OpenCL C kernel language.
Kernels are viewed as indivisible functions and as such the nature of these kernels is fixed for all executions, and as such, a kernel does not suffer from the phase-transitions that are common when looking at larger scientific codes.
The compositions of all kernels form a full accelerator agnostic implementation for any larger scientific code.


A benefit of the fixed/static nature of OpenCL kernels is that the collection of the characteristics is also constant.
Such that, instrumentation of a kernel to measure computation, memory, branching and parallelism characteristics of a program are largely unchanged between run and are independent of data set.
To this end, the Architecture Independent Workload Characterisation (AIWC) tool has been developed.
This tool collects 40+ metrics that indicate computation, memory, branching and parallelism characteristics on a per OpenCL kernel basis.
It simulates an OpenCL device using the Oclgrind tool and the AIWC plugin analyses the program trace, memory locations accessed, and thread-states to generate the metrics.
Metrics can be collected quickly since it is a multi-threaded simulator.
AIWC features, are generated for each kernel invocation and can be embedded as a comment into the header of OpenCL kernel codes -- either in plain-text source or in the SPIR format.


Separately, additional work in this thesis comprises of the extension of a benchmark suite.
This was needed since programs that are representative of scientific HPC applications which are capable of execution over a wide range of accelerators are few and far between, specifically with portable performance and reproducible results.
Additionally, until this work was undertaken, the available OpenCL benchmark suites were not rich enough to adequately characterise performance across the diverse range of applications or accelerator devices of interest.
Thus this thesis presents an enhanced version of the OpenDwarfs OpenCL benchmark suite -- denoted the OpenDwarfs Extended Benchmark Suite (ODE) -- which was developed with a strong focus placed on the robustness of applications, the curation of additional benchmarks with an increased emphasis on correctness of results and the selection of 4 problem sizes.


LibSciBench was added to ODE, this includes high precision timers along with support for the collection of PAPI -- hardware performance counters -- events and energy usage information.
Runtime, or elapsed execution times, of all ODE benchmarks, were collected on 15 unique accelerator devices suitable for current HPC systems.
Collection of these times occurs at a per kernel level along with instrumentation of other events common to the OpenCL setting, such as memory setup and timing data movement to accelerator devices.
In addition to the higher level, total elapsed application execution time was also collected.


Independently, the random forest algorithm is a very powerful pattern recognition technique.
It is supervised learning algorithm that builds multiple decision trees and merges them together to achieve an accurate and stable prediction.
The final major contribution of this thesis is the development of a predictive model, using the random forest algorithm, to show the link between AIWC features and execution times over all devices.
Thus, the AIWC tool was run and the features collected from all the kernels of ODE.
These AIWC metrics were used as predictor variables into the random forest, and the time data of kernels from the experimental methodology was used as the response variables to indicate predictions.
The accelerators examined in these predictions range from CPU, GPU and MIC, however, the methodology finally presented is expected to perform over DSP and FPGA also.


The final model performs very well and is capable of highly accurate predictions which on average differ from the measured experimental run-times by 1.1%, which correspond to actual execution time mispredictions of 8 $\mu s$ to 1 secs according to problem size.
The model is capable of predicting execution times for specific devices based on the computational characteristics captured by the AIWC tool, which in turn, provides a good prediction of an accelerator devices execution time needed for a real-world scheduler for nodes of future super-computing systems.

<!-- Restatement of the problem -->

##The Problem

The future of supercomputing comprises several heterogenous devices at the node level.
This complicates the already complicated issue of scheduling code to the node in order to fully utilise supercomputing facilities.


<!-- Restatement of the response -->


##The Solution

Architecture Independent Workload Characterisation (AIWC) tool is capable of analysing kernels in order to extract a set of predefined features or characteristics.
These metrics are used for creating the prediction model to evaluate the performance of OpenCL kernels on different hardware devices and settings.
Such a model can then be applied as a prognosis tool to predict the performance of an application for a given platform without any additional instrumentation.
This prediction adds information that can be incorporated into existing HPC schedulers and has no run-time overhead -- codes are examined one time by the developer when instrumenting with AIWC and these, in turn, are embedded into the header of each kernel code to be evaluated by the scheduler at the time of scheduling.


<!-- Roadmap -->

##Roadmap


Chapter 2 discusses the extensions added to the OpenDwarfs Benchmarking Suite in ODE.
Chapter 3 highlights the construction, design decisions made and usage of the AIWC tool.
Chapter 4 develops the prediction model and examines the accuracy of the final predictions.
Chapter 5 discusses conclusions of this thesis and the future work required for the predictive model to be incorporated into scheduling on future Supercomputing systems.

