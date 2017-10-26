---
title: Mining for Dwarfs on Accelerators, Thesis Map
author: Beau Johnston
date: \today
---

+----------------------------------------------------------------------+-----------------------+
|Remaining Tasks                                                       | Date To Complete Task |
+======================================================================+=======================+
|Write Chapter 2                                                       | Early Nov             |
+----------------------------------------------------------------------+-----------------------+
|Write Chapter 3                                                       | Mid Nov               |
+----------------------------------------------------------------------+-----------------------+
|Finish full analysis paper for Chapter 4                              | Late Nov              |
+----------------------------------------------------------------------+-----------------------+
|Write Chapter 4                                                       | Early Dec             |
+----------------------------------------------------------------------+-----------------------+
|Finish feature extraction paper                                       | Late Dec              |
+----------------------------------------------------------------------+-----------------------+
|Write Chapter 5                                                       | Mid Jan               |
+----------------------------------------------------------------------+-----------------------+
|Modelling and prediction paper                                        | Early Feb             |
+----------------------------------------------------------------------+-----------------------+
|Write Chapter 6                                                       | Mid Feb               |
+----------------------------------------------------------------------+-----------------------+
|Write Chapter 7 -- Conclusions                                        | End Feb               |
+----------------------------------------------------------------------+-----------------------+
|Write Chapter 1 and Abstract                                          | Early Mar             |
+----------------------------------------------------------------------+-----------------------+
|Submit draft to supervisor                                            | Early Mar             |
+----------------------------------------------------------------------+-----------------------+
|Make changes and submit                                               | Early Apr (end of     |
|                                                                      |scholarship)           |
+----------------------------------------------------------------------+-----------------------+


#Thesis Rationale


1. *Thesis Statement* "Scientific high performance computer systems are becoming increasingly heterogeneous because certain classes of accelerators are more suitable for particular classes of applications or “dwarfs”.
Automatic classification of a program binary in terms of dwarfs will allow the efficient scheduling of work to the most appropriate accelerator."

In other words: supercomputers are installing hardware for specialised computation, knowing what features of code best map to types of hardware is essential for achieving better results -- reduced time and energy -- in this space.

2.  *This thesis contributes knowledge by:*

Examining the performance results, such as time and energy consumption, when performing scientific tasks on high-performance computing (HPC) systems.
These systems are comprised of dedicated accelerator hardware and thus being able to schedule a compute task to the most appropriate device requires a knowledge the performance of each component.
This component study and the subsequent analysis is the major contribution of this thesis and has occurred by evaluating OpenCL programs on a wide range of accelerators.
Subsequently, this study has resulted in an extended benchmark suite being developed.
Which allows for a variety of workload sizes for each application, and also better encompasses scientific workload diversity by adding more applications representative of the dwarf taxonomy -- common patterns of communication and computation common in scientific computing.
Additionally, this thesis examines whether structural characteristics, in the code, of a compute task, can be used to select the best accelerator.
To this end, a feature space analysis is presented using conventional Principal Component Analysis methods albeit on the updated suite.
A comparison between this methodology and instrumentation (`grinding`) approaches is presented.
This work culminates in a model which in turn is used to predict a compute task suitability to the optimal type of accelerator.

3. *This study is important because:*

High performance computing (HPC) hardware is becoming increasingly heterogeneous.
A major motivation for this is to reduce energy use; indeed, without significant improvements in energy efficiency, the cost of exascale computing will be prohibitive.
For many systems, this was made possible by highly energy-efficient Nvidia Tesla P100 Graphics Processing Units (GPUs).
In addition to GPUs, future HPC architectures are also likely to include nodes with Field-Programmable Gate Array (FPGA), Digital Signal Processor (DSP), Application-Specific Integrated Circuit (ASIC) and Many Integrated Core (MIC) components.
A single node may be heterogeneous, containing multiple different computing devices; moreover, a HPC system may offer nodes of different types.

This dissertation seeks to answer the question: for a given architecture with a variety of computing devices and a given set of computational tasks, which is the best choice of device for each task?
Furthermore, does the best choice of device vary depending on whether the primary concern is time to solution or energy efficiency?
Finally, can the structural characteristics of a computational task be used to determine which accelerator architecture should be used?


4. *Key research question:* Can the structure of OpenCL kernels be used determine the type of accelerator on which it should be run?

Sub-questions:


* How does OpenCL runtime perform on a variety of platforms common in today's HPC systems? Indeed, is there any overhead against the theoretical scaling of algorithms relative to the achieved performance on this hardware? If so, is this worth the hardware agnosticism the framework provides?
* Does problem size affect the optimality of a dwarf and its suitability for an accelerator type?
* What types of workloads, or what dwarfs, have accelerator results where time and energy results are strongly correlated -- indeed are there dwarfs that defy this trend?
* Do certain accelerator types always perform best under all applications in a given dwarf?
* Are all dwarfs suited to one type of accelerator?
* Does Phase-Shifting occur within OpenCL kernels?
* Are the principal components used when performing microarchitecture independent analysis transferable to architecture independent analysis.
* How is the feature space generated from instrumentation tools -- such as `oclgrind` -- comparable to those generated from hardware monitoring processes -- namely PIN. Is it more accurate or applicable to the OpenCL platform.
* In what ways does incorrectly setting tuning arguments and compiler flags effect the features-space of an OpenCL kernel?


#Chapter by chapter synopsis

**Introduction**

The introduction introduces the current trend in high-performance supercomputing systems -- they are becoming more heterogeneous.
The justification for this is because they are more efficient for certain applications.
Following this motivation, the main research question is presented: "Scientific high performance computer systems are becoming increasingly heterogeneous because certain classes of accelerators are more suitable for particular classes of applications or “dwarfs”."
The ultimate finding of this thesis is then presented, the benefits of being able to automatically schedule OpenCL kernels to the optimal type of accelerator is large, it introduces the question around how this can occur.

Subheadings:

* Accelerators in HPC
* Evaluating performance of accelerators
* Bundling Dwarfs
* Generating a Feature-Space
* Modelling Dwarfs and their Features
* Publications
* Contribution of this work
* Automatic scheduling of OpenCL kernels to the optimal accelerator type
* Thesis Structure



**Background Information and Related Work (lit review)**

The chapter presents background information, terminology and the related work drawn upon in the rest of this thesis.
It provides a background for readers who might not be familiar with workload characterisation of programs or the performance metrics and composition of current HPC systems.
It begins with the definition of accelerators and a brief survey regarding their use in supercomputing and presents the hardware agnostic programming framework -- OpenCL.
The dwarf taxonomy is introduced along with a representative sample of benchmark suites which incorporate this taxonomy.

Subheadings:

* Accelerator Architectures and the increasing diversity in HPC
* The Open Compute Language Setting
* The Dwarf Taxonomy
* Benchmark Suites
    * Rodinia
    * OpenDwarfs
    * SHOC
* Autotuning
* Off-line Ahead-of-Time Analysis
* Phase-Shifting
* Scaling w.r.t.
    * Frequency
    * Core count
* Program Diversity Analysis
* OclGrind: Debugging OpenCL kernels via simulation
* Time and Energy -- a non-linear relationship
* Schedulers and Predicting the most Appropriate Accelerator



**Evaluating the suitability of OpenCL Workloads for High-Performance Computing**

This chapter presents two separate case studies focused on answering the sub-question on:

*How does OpenCL runtime perform on a variety of platforms common in today's HPC systems?
Indeed, is there any overhead against the theoretical scaling of algorithms relative to the achieved performance on this hardware?
If so, is this worth the hardware agnosticism the framework provides?*

Case study 1 focuses on addressing the practical scaling of OpenCL when increasing core-count of hardware against the theoretical algorithmic scaling.
The results presented directly evaluate the overhead and penalties incurred when using the OpenCL framework.
Another analysis of scaling is presented in case study 2, which focuses on the achievable scaling of OpenCL when given an increasing clock frequency.

Additionally both case studies show energy usage being strongly tied to execution times which helps motivate the sub-question:
*What types of workloads, or what dwarfs, have accelerator results where time and energy results are strongly correlated -- indeed are there dwarfs that defy this trend?*

Subheadings:

* Case Study 1: Compute Scaling of a Parallel Huffman Decoding Algorithm on increasingly multi-core devices
* Case Study 2: An Energy Study of OpenCL Gaussian Elimination Workloads in the Embedded Accelerator setting



**The Dwarf Accelerator Mapping**

This chapter presents an extension of an existing benchmark suite -- OpenDwarfs.
The extension focuses on adding additional benchmarks to better represent each Dwarf along with supporting a range of 4 problem sizes for each application.
The rationale for the latter is to survey the range of applications over a diverse set of HPC accelerators across increasing amounts of work, which allows for a deeper analysis of the memory subsystem on each of these devices.
The corresponding analysis directly addresses the sub-question around: *Does problem size affect the optimality of a dwarf and its suitability for an accelerator type?*

Next, the results are grouped according to dwarf instead of as independent results.
Analysis on these dwarf groups shows that when:

* focusing on energy analysis, certain dwarfs have results where energy is uncorrelated to execution time,
* particular accelerator types do perform best under all applications encompassing a dwarf,
* and that all dwarfs are not suited to one type of accelerator -- for instance GPU type accelerators are unsuited to the combinational-logic dwarf.

Subheadings:

* Experimental Evaluation
* Sensibly Grouping The Data
* Evaluation - Dwarfing The Accelerator Selection Problem
* The impact of Scale -- An analysis of clock frequency on accelerator selection
* The Impact of Tuning


**Finding the Features of a Dwarf**

This chapter focuses on generating the feature-space representation of a dwarf.
The methodology starts by reproducing the results shown in established literature -- using Microarchitectural hardware counters followed by principal component analysis, and compares these results to the newly generated feature-spaces using simulator instrumentation tools.

The results presented are used to evalute the sub-questions regarding:

* *Does Phase-Shifting occur within OpenCL kernels?*
* *Are the principal components used when performing microarchitecture independent analysis transferable to architecture independent analysis.*
* *How is the feature space generated from instrumentation tools -- such as `oclgrind` -- comparable to those generated from hardware monitoring processes -- namely PIN. Is it more accurate or applicable to the OpenCL platform.*
* *In what ways does incorrectly setting tuning arguments and compiler flags effect the features-space of an OpenCL kernel?*

Subheadings:

* Methodology
* Results
* Simulate with Care
* The Costs of Off-line Ahead-of-Time Analysis
* Phase Shifting
* The Impact of Tuning



**Application-Accelerator Prediction**

This Chapter uses the performance results presented in Chapter 4 and the feature-spaces presented in Chapter 5 to develop a model.
The feature-space first undergoes a reduction to simplify the space from the application domain to one focused on the superset of applications -- dwarfs.
This model is then used to predict an optimal accelerator type for new OpenCL kernels, ones unused for the model development.
The evaluation of this model is presented and the corresponding feasibility addresses the primary question raised by this thesis, namely: *Can the structure of OpenCL kernels be used determine the type of accelerator on which it should be run?*

Subheadings:

* Principal Component Analysis: The Basis for Prediction
* Clustering Dwarfs in Feature-Space
* Dwarf Modelling: A GLM approach
* Making Predictions from the Model and Experimental Results



**Conclusions and Future Work**

The conclusion discusses the feasibility of incorporating the predictive model into HPC scheduler systems, this also forms the basis for a discussion on the future works.
On overall summary of the accuracy of the predictive model is also presented.
Finally, the caveats and assumptions used when generating the results of Chapters 4, 5, and 6 is outlined.

Subheadings:

* The benefits of accurate prediction
* Future Work



