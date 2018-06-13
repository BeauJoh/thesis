#Evaluating the suitability of OpenCL Workloads for High-Performance Computing

In order for the OpenCL language to form the basis of an hardware agnostic framework to be used in HPC, there first needs to be an analysis around its viability.
The fairest way to assess this framework is to measure the achieved performance and compare these results to other frameworks/languages or against the peak performance on which the accelerator is theoretically capable.
The former is addressed in Case Study 1, while the latter is primarily examined in Case Study 2.

Initially, Case Study 1 serves as an evaluation of the OpenCL framework, namely, as an examination of the portability of OpenCL against the performance of native implementations.
During this survey, the scalability of a developed parallel Huffman Decoding algorithm is examined as an application, but this is also transferable to other compute bound applications.
For the comparison, a C version of the algorithm is compared to the OpenCL implementation and evaluated on a high-end Intel CPU.
During this experiment an increasing number of CPU cores are disabled to show the performance of OpenCL in response to utilization of available cores, this is also compared to the theoretical scaling of the algorithm.
In the second part of this Case Study, the same OpenCL implementation is compared to an identical CUDA version and executed on the same modern Nvidia GPU, thus emphasising a comparison of native performance.
This performance evaluation occurs as a collection of timing and energy consumption metrics, where the execution of 4 compute kernels is measured.
The methodology to collect the energy metrics is also presented.

Case Study 2 is also an evaluation of OpenCL but focuses on next generation HPC hardware, specifically ARM CPUs.
Since a large motivation for this research is on automatically selecting the most appropriate accelerator on future SC systems, a study around the suitability of OpenCL on one of the major components was needed.
Systems such as Fujitsu's Post-K and Cray's CS-400, which have already been discussed in [Section @sec:sec:chapter2-accelerator-architectures], will be comprised of energy efficient ARM host cores and will serve as the backbone on many SC nodes.
Additionally, the performance of scientific workloads on these devices is largely unknown.
Yet, the bulk of computation required in HPC and SC is scientific.
In this case study, a presentation on the analysis of one such scientific code, in the form of Gaussian Elimination, is evaluated.
Both execution time and energy consumed was measured on a range of embedded accelerator System-on-a-Chip (SoC).
These include three ARM CPUs and two mobile GPUs.
Embedded SoCs are used, since at the time of publication the availability of high-end ARM CPU systems is very low.
Understanding how these low power devices perform on scientific workloads is critical in the selection of appropriate hardware for these supercomputers, for how could estimations of performance over tens of thousands of chips be accurate if the performance on one is largely unknown?
During this survey, the OpenCL framework is evaluated on a Gaussian Elimination application.
The resultant energy and execution time measurements are compared to the theoretical peak performance of each chip, to highlight and evaluate the inefficiencies in the OpenCL runtime.
On CPU architectures, this study also presents an analysis on the impact of clock frequency setting.
Namely, the findings that execution time and the corresponding energy usage is correlated over compute-bound applications has already been determined by Hsu et al. [@hsu2000compiler] and many others, but that clock frequency should be considered when selecting an ARM CPU accelerator from an OpenCL runtime, this is a new discovery and is required to perform automatic scheduling of OpenCL workloads -- one of the motivations of this thesis.
The clock frequency study also consists of an evaluation of the hardware relative to the peak theoretical performance.

<!--
How does OpenCL runtime perform on a variety of platforms common in today’s HPC systems?
Indeed, is there any overhead against the theoretical scaling of algorithms relative to the achieved performance on this hardware?
If so, is this worth the hardware agnosticism the framework provides?
-->

## Case Study 1: Compute Scaling of a Parallel Huffman Decoding Algorithm on increasingly multi-core devices

\todo{include the huffman paper here}

## Case Study 2: An Energy Study of OpenCL Gaussian Elimination Workloads in the Embedded Accelerator setting

\todo{include the gaussian elimination paper here}

## Final findings

The major findings of Case Study 1 is that OpenCL incurs minor performance overheads (in both time and energy) relative to native implementations but highly portable nature of the framework means it is suitable for the scope of this thesis.


