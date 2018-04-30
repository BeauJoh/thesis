# Introduction

<!-- 
For italic, add one * on either side of the text
For bold, add two * on either side of the text
For bold and italic, add _** on either side of the text
-->

<!-- Introduction to the Introduction -->

Supercomputers are becoming increasingly heterogenous.
At an individual node, there is an increasing trend to use specialised hardware -- known as accelerators -- which can expedite the computation of codes from particular classes of scientific workloads.
The next generation of these systems have been designed to incorporate a greater number of accelerators.
For instance, the CAPI and NVLINK technologies included in the latest IBM POWER9 processor offers a high-speed interconnect which allows the rapid movement data between processor and accelerator -- NVIDIA Graphical Processing Unit (GPU) with NVLINK, and CAPI supporting Altera Field-Programmable Gate Array (FPGA), Intel Central Processing Unit (CPU) co-processors to AMD CPU and GPU devices.
The POWER9 is set to feature in the upcoming Summit and Sierra Supercomputers.
The support from mainframe vendors for a greater mix of heterogenous devices indicates this is the new direction of supercomputing.
However, this development is recent, and as such the scheduling of workloads to suitable accelerator is a new problem.

Independently, the characteristics of a scientific code, specifically around computation, memory, branching and parallelism, are independent of any particular device on which they may be finally executed.
The metrics used to quantify each of these characteristics can be collected during program execution on a simulator.
In other words, provided they are collected over a representative workload, a graph traversal program maintains the characteristics of a graph traversal program regardless of problem size.
Moreover, these metrics can be used to accurately predict the execution time on each accelerator in a heterogenous system.

This thesis outlines the methodology required to perform runtime predictions for any given code -- provided the feature metrics are pre-generated -- for any accelerator device.
A benchmark suite is extended, a characterisation tool developed, and a model is generated to achieve the task.
This research is of benefit to the scheduling of compute codes to the most appropriate device which in turn provides essential information for scheduling, to better utilise the next generation of supercomputers.
Without significant improvements in effectively using accelerators on these next generation mainframes, the cost of exascale computing and their corresponding energy efficiency will be prohibitive.

<!-- Context -- a brief on how the proposed solution works -->

##Context

OpenCL setting
AIWC developed
metrics AIWC collects
Embedded into the header of codes.

Runtime data over a range of devices has been measured independently.
A predictive model has been developed to 

<!-- Restatement of the problem -->

##The Problem

<!-- Restatement of the response -->

##The Solution

<!-- Roadmap -->

##Roadmap

The thesis builds on and contributes to work in the areas of High Performance Computing in particular workload scheduling for efficient supercomputing.
Original contributions include:  is enabling workloads to be autonomously classified, this classification is used to autonomously map a new application code to the most suitable type of accelerator. These accelerators  are increasingly becoming the powerhouse components of these supercomputer systems.
Although studies in diversity analysis for assembling benchmark suites have examined workload classification they have not been used for a general accelerator predictive model.
As such, this study provides additional insight into techiques and tools, along with a wider assembleage of benchmark suite.
This study is important to the HPC scientific computing community because scheduling generic blocks of code to the most suitable device will allow a significant reduction in power consumption and a better utilisation of supercomputers.
But what excited me the most about this study is doing the analysis and prediction.


## Accelerators in HPC

<!--
[X] components of high performance computers are becoming increasingly heterogeneous
[.] major motivation for this is energy consumption
[.] list of example current supercomputers from the green 500 and top 100
[.] discuss corresponding difference in energy usage between the green and top systems
[.] show survey results that the trend in newer systems is adding a wider mix of accelerators, and the corresponding decreased energy use.
[.] Make a statement around the NVIDIA P100 GPU having great FLOPs Per Watt performance.
[.] Accelerator hardware manufacturers recognise this and is demonstrated by IBM's Power9 system support NVLINK.
[.] What is NVLINK, what does it allow?
[.] These HPC systems are comprised of more than simply GPUs, for instance the added high speed interconnect -- CAPI for FPGA, MIC and ASIC devices.
[.] What future supercomputers have already proposed high accelerator comprised systems? List them.
-->

High performance computing (HPC) hardware is becoming increasingly heterogeneous.

This increase takes the form of using specialised devices, typically from general purpose computing, but re-targeted for scientific workloads.
For instance, GPUs were originally developed to fulfil the increased graphics needs in the video game industry.
Thankfully, the kinds of computation required when rendering 3D environments and the structure of the hardware dedicated to improving it, has similar computation and communication patterns in.
Examples of common workloads that follow similar types of computation includes volumetic signal processing tasks, such as filtering, or simulating movement of particles through matter.

Thankfully, these are the types of workloads common in large scientific computer systems for this reason they are defined as accelerators since they accelerate specific types of computation.

Other devices used in high performance computer systems include CPU co-processing hardware.
These are suited for more generic compute tasks such as graph traversal patterns that involve accessing random segments of memory.

DSP hardware
MIC
FPGAs reconfigurable hardware
ASICs are dedicated hardware



An additional major motivation for this increase in heterogeneity is to reduce energy use; indeed, without significant improvements in energy efficiency, the cost of exascale computing will be prohibitive.
From June 2016 to June 2017, the average energy efficiency of the top 10 of the Green500 supercomputers rose by 2.3x, from 4.8 to 11.1 gigaflops per watt.\cite{feldman_2017}
For many systems, this was made possible by highly energy-efficient Nvidia Tesla P100 GPUs.
In addition to GPUs, future HPC architectures are also likely to include nodes with FPGA, DSP, ASIC and MIC components.
A single node may be heterogeneous, containing multiple different computing devices; moreover, a HPC system may offer nodes of different types.
For example, the Cori system at Lawrence Berkeley National Laboratory comprises 2,388 Cray XC40 nodes with Intel Haswell CPUs, and 9,688 Intel Xeon Phi nodes~\cite{declerck2016cori}.
The Summit supercomputer at Oak Ridge National Laboratory is based on the IBM Power9 CPU, which includes both NVLINK~\cite{morgan_2016}, a high bandwidth interconnect between Nvidia GPUs; and CAPI, an interconnect to support FPGAs and other accelerators.~\cite{morgan_2017}
Promising next generation architectures include Fujitsu's Post-K~\cite{morgan_2016_postk}, and Cray's CS-400, which forms the platform for the Isambard supercomputer~\cite{feldman_2017_isambard}.
Both architectures use ARM cores alongside other conventional accelerators, with several Intel Xeon Phi and Nvidia P100 GPUs per node.



Components of High Performance Computers are becoming increasingly heterogenous.





## Evaluating performance of accelerators


* Evaluating the performance of these HPC systems is big business.
* Conventional benchmarking use LINPACK, list reasons why this is an undesirable panacea of measurement metrics.


## Bundling Dwarfs

Applications have been classified according to dwarf taxonomy.
A study at MIT led to the dwarf taxonomy being developed
The Dwarf Taxonomy was developed as a means of representing common scientific workloads executed on typical high performance computing workloads.
These benchmarks are treated as general scientific blocks of commonly use codes that represent all scientific applications.
The premise for this is that the all applications executed on high performance computer system scientific computing systems are comprised of any of these workloads.
They are used in HPC syssetems as a means of perfo suibtable selescting benchmarks nin ben whe used when curating new benchmark suites .
Sample dwarfs include Dense linear alagebra , sparcse linear algerba

The Dwarf Taxonomy was developed as a means of representing common scientific workloads executed on all high performance computing systems.
Dwarfs are patterns of computation and communication.
High performance computer systems typically execute applications comprised of dwarfs.

## Generating a Feature-Space


## Modelling Dwarfs and their Features


## Publications
This thesis reports on research conducted into the performance of OpenCL algorithms on 

<!--
[.] List Papers and what they add
-->

## Contribution of this work

Examining the performance results, such as time and energy consumption, when performing scientific tasks on high-performance computing (HPC) systems.
These systems are comprised of dedicated accelerator hardware and thus be- ing able to schedule a compute task to the most appropriate device requires a knowledge the performance of each component.
This component study and the subsequent analysis is the major contribution of this thesis and has occurred by evaluating OpenCL programs on a wide range of accelerators.
Subsequently, this study has resulted in an extended benchmark suite being developed.
Which allows for a variety of workload sizes for each application, and also better encompasses scientific workload diversity by adding more applications representative of the dwarf taxonomy – common patterns of communication and computation common in scientific computing.
Additionally, this thesis examines whether structural characteristics, in the code, of a compute task, can be used to select the best accelerator.
To this end, a feature space analysis is presented using conventional Principal Component Analysis methods albeit on the updated suite.
A comparison between this methodology and instrumentation (grinding) approaches is presented.
This work culminates in a model which in turn is used to predict a compute task suitability to the optimal type of accelerator.



## The importance of automatic scheduling of OpenCL kernels to the optimal accelerator type

Given the increased use of accelerators in HPC, the ability to predict the optimal type of accelerator according to an OpenCL kernel is paramount.
As already discussed selecting the most appropiate accelerator for either time or energy -- both are usually correlated but not always -- will save many resources.

A separate but larger motivator for this work is the exascale target of SC systems.

For instance, when we examine the current top 3 supercomputers on the Top500:
\todo[inline]{convert urls to bibtex}


1. TaihuLight:
    * achieves 93 PFLOPS
    * and consumes 15.3 megawatts (MW)
    * ~41.9k nodes each consisting of Sunway 26010 manycore (256) 64-bit RISC CPUs [https://www.top500.org/news/china-tops-supercomputer-rankings-with-new-93-petaflop-machine/]
2. Tianhe-2:
    • 33.8 PFLOPS
    • 17.6 MW -- 24 MW with cooling
    • 16k nodes, each comprised of 2 $\times$ Intel Xeon E5-2692 CPUs (12 cores) and 3 $\times$ Xeon Phi MICs
3. Piz Daint:
    • 9.7PFLOPS
    • 1.3MW
    • 5.3k nodes, each node contains a XeonE5-2690 (12 cores) and NVIDIA Tesla P100

For perspective, a large wind turbine typically produces ~1 MW, whereas large coal and nuclear power plants generate hundreds of megawatts to gigawatts.

If we examine the most efficient (FLOPS/WATT) supercomputer the Piz Daint and extrapolate, by increasing the number of nodes by 100 and assume a linear scaling it would almost -- theoretically provide exascale with computing 970 PFLOPS, but would consume 130 MWs and thereby require a powerplant to keep operational.
The assumption of increasing components linearly scaling with power consumption is a broad and unrealistic assumption to make, but the emphasis of this argument should not be placed on the model, more the difference in scale.
Namely, the ability to select the most appropriate accelerator on each node -- even if the performance savings are small on the node -- will add up and significantly improve the margin on these future Exascale heterogenous supercomputer systems.


\todo[inline]{correct this ratio and cite it} 5 of the top 10 from the Top500 list show current systems in use which benefit from the use of highly energy-efficient Nvidia Tesla P100 GPUs, however (and as previously mentioned) the next generation systems will comprise of a wider range of accelerators.
High speed and bandwidth memory interconnects, such as CAPI, means it is also likely to include nodes with Field-Programmable Gate Array (FPGA), Digital Signal Processor (DSP), Application-Specific Integrated Circuit (ASIC) and Many Integrated Core (MIC) components.
A single node may be heterogeneous, containing multiple different computing devices; moreover, a HPC system may offer nodes of different types.
Many of these next generation systems will benefit from the ability to effectively use the right tool for the job, or accelerator for the kernel.
The importance of these findings will be increasingly important in the age of exascale supercomputing.



## Thesis Structure

This dissertation seeks to answer the question: for a given architecture with a variety of computing devices and a given set of computational tasks, which is the best choice of device for each task? Furthermore, does the best choice of device vary depending on whether the primary concern is time to solution or energy efficiency?
Finally, can the structural characteristics of a computational task be used to determine which accelerator architecture should be used?

Throughout the studies and findings presented in this thesis, several sub-questions arise and are summarily addressed, these include:


* How does OpenCL runtime perform on a variety of platforms common in today's HPC systems? Indeed, is there any overhead against the theoretical scaling of algorithms relative to the achieved performance on this hardware? If so, is this worth the hardware agnosticism the framework provides?
* Does problem size affect the optimality of a dwarf and its suitability for an accelerator type?
* What types of workloads, or what dwarfs, have accelerator results where time and energy results are strongly correlated – indeed are there dwarfs that defy this trend?
* Do certain accelerator types always perform best under all applications in a given dwarf?
* Are all dwarfs suited to one type of accelerator?
* Does Phase-Shifting occur within OpenCL kernels?
* Are the principal components used when performing microarchitecture
independent analysis transferable to architecture independent analysis.
* How is the feature space generated from instrumentation tools – such as oclgrind – comparable to those generated from hardware monitoring processes – namely PIN. Is it more accurate or applicable to the OpenCL
platform.
* In what ways does incorrectly setting tuning arguments and compiler flags effect the features-space of an OpenCL kernel?

The structure of this dissertation is presented as follows:

**Chapter 2** presents background information, terminology and the related work drawn upon in the rest of this thesis.
It provides a background for readers who might not be familiar with workload characterisation of programs or the performance metrics and composition of current HPC systems.
It begins with the definition of accelerators and a brief survey regarding their use in supercomputing and presents the hardware agnostic programming framework – OpenCL.
The dwarf taxonomy is introduced along with a representative sample of benchmark suites which incorporate this taxonomy.

**Chapter 3** evaluates the suitability of OpenCL workloads for High-Performance Computing.
The suitability study presents two separate case studies focused on answering the sub-questions on:

*How does OpenCL runtime perform on a variety of platforms common in today's HPC systems? Indeed, is there any overhead against the theoretical scaling of algorithms relative to the achieved performance on this hardware? If so, is this worth the hardware agnosticism the framework provides?*

Case study 1 focuses on addressing the practical scaling of OpenCL when increasing core-count of hardware against the theoretical algorithmic scaling.
The results presented directly evaluate the overhead and penalties incurred when using the OpenCL framework.
Another analysis of scaling is presented in case study 2, which focuses on the achievable scaling of OpenCL when given an increasing clock frequency.

Additionally both case studies show energy usage being strongly tied to execution times which motivates the sub-question:
*What types of workloads, or what dwarfs, have accelerator results where time and energy results are strongly correlated – indeed are there dwarfs that defy this trend?*

**Chapter 4**  presents an extension of an existing benchmark suite -- OpenDwarfs.
The extension focuses on adding additional benchmarks to better represent each Dwarf along with supporting a range of 4 problem sizes for each application.
The rationale for the latter is to survey the range of applications over a diverse set of HPC accelerators across increasing amounts of work, which allows for a deeper analysis of the memory subsystem on each of these devices.
The corresponding analysis directly addresses the sub-question around: *Does problem size affect the optimality of a dwarf and its suitability for an accelerator type?*

Next, the results are grouped according to dwarf instead of as independent results.
Analysis on these dwarf groups shows that when:

* focusing on energy analysis, certain dwarfs have results where energy is uncorrelated to execution time,
* particular accelerator types do perform best under all applications encompassing a dwarf,
* and that all dwarfs are not suited to one type of accelerator -- for instance GPU type accelerators are unsuited to the combinational-logic dwarf.


*Chapter 5* focuses on generating the feature-space representation of a dwarf, it presents a methodology to generate architectural independent 
The methodology starts by reproducing the results shown in established literature -- using Microarchitectural hardware counters followed by principal component analysis, and compares these results to the newly generated feature-spaces using simulator instrumentation tools.

The results presented are used to evalute the sub-questions regarding:

* *Does Phase-Shifting occur within OpenCL kernels?*
* *Are the principal components used when performing microarchitecture independent analysis transferable to architecture independent analysis.*
* *How is the feature space generated from instrumentation tools -- such as `oclgrind` -- comparable to those generated from hardware monitoring processes -- namely PIN. Is it more accurate or applicable to the OpenCL platform.*
* *In what ways does incorrectly setting tuning arguments and compiler flags effect the features-space of an OpenCL kernel?*




