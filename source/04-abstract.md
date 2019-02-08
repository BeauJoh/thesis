# Abstract {.unnumbered}

The next-generation of supercomputers will feature a diverse mix of accelerator devices.
The increase in heterogeneity is explained by the nature of supercomputing workloads -- certain devices offer acceleration, or a shorter time to completion, for particular application programs.
Certain characteristics of these programs are fixed and impose fundamental limitations on the workloads regardless of which accelerator is used for the computation; for instance, a graph traversal program always exhibits the same high-branch and low-computation properties regardless of what device is used to execute it.
To support efficient scheduling on High Performance Computing (HPC) systems it is necessary to make accurate performance predictions for workloads on varied compute devices, which is challenging due to diverse computation, communication and memory access characteristics which result in varying performance between devices.
On HPC systems a single node may feature a Graphics Processing Unit (GPU), a Central Processing Unit (CPU), and a Field-Programmable Gate Array (FPGA) or Many Integrated Core (MIC) device.
This work presents a device independent predictor -- a methodology to use device-independent characteristics of scientific codes to select the optimal accelerator device with regard to execution time or energy expenditure.

<!-- For a scientific application to run on multiple devices Open Compute Language (OpenCL) is a suitable programming model for HPC systems.-->
Open Compute Language (OpenCL) is a programming model designed to facilitate the development of application codes capable of running on multiple different devices.
First released in late 2008, it defines a C-like language used to write kernels that can be compiled to run on the different devices.
Implementations of the current release (2.2) exist for CPUs, GPUs, FPGAs and the Intel MIC systems, and as such, there is increasing interest in the use of OpenCL for developing scientific applications designed to run on next-generation supercomputer systems.

This thesis seeks to use the device-independent characteristics of an OpenCL code to select the optimal accelerator device on which to execute each OpenCL kernel.
Consideration is given both to execution time and energy usage.

The first focus of this work is to present a comprehensive benchmark suite for OpenCL in the heterogeneous HPC setting: an extended and enhanced version of the OpenDwarfs OpenCL benchmark suite.
Our extensions improve the portability and robustness of the applications, the correctness of results and the choice of problem size, and diversity of coverage through the inclusion of additional application patterns.
This work manifests in performance measurements on a set 15 devices and over 12 applications.

We next present our Architecture Independent Workload Characterization (AIWC) tool which characterizes OpenCL kernels according to a set of architecture-independent features.
Features are measured by counting target characteristics which are collected during program execution in a simulator.
They are presented as 28 metrics in four categories: parallelism -- how well an algorithm scales in response to core count; compute -- the diversity of instructions; memory -- working memory footprint and entropy measurements which correspond to caching characteristics; and control -- branching and program flow.
The metrics collected are primarily used in the prediction of execution times, but since they are representative of structural characteristics of the underlying program and are free from architectural traits, they can be used in diversity analysis in benchmark suites, identifying program requirements which allows the automatic calculation of theoretical peak performance for a given device and examining the differences in kernels to show the phase-transitional properties of the application codes.
We also discuss the design decisions made to collect AIWC features.

Finally, this work culminates in a methodology which uses AIWC features to train a random forest model capable of predicting accelerator execution times.
We use this model to predict execution times for a set of 37 computational kernels running on 15 different devices representing a broad range of CPU, GPU and MIC architectures.
The predictions are highly accurate, differing from the measured experimental run-times by an average of only 1.2%.
A previously unencountered code can be instrumented using AIWC to allow performance prediction across the full range of modelled devices.
The results suggest that this methodology supports the correct selection of the most appropriate device for a previously unencountered code, and is highly relevant to efficiently schedule codes to emerging heterogeneous supercomputing systems.


\pagenumbering{roman}
\setcounter{page}{1}
\newpage

