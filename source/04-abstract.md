# Abstract {.unnumbered}

The next-generation of supercomputers will feature a diverse mix of accelerator devices.
The increase of heterogeneity is explained by the nature of these devices -- certain accelerators offer acceleration, or a shorter time to completion, for particular programs.
Characteristics of these programs are fixed and impose fundamental limitations to the workloads regardless of which accelerator is used for computation; for instance, a graph traversal program always exhibits the same high-branch and low-computation properties of graph traversal regardless of what device is used to execute it.
To support efficient scheduling on HPC systems it is necessary to make accurate performance predictions for workloads on varied compute devices, which is challenging due to diverse computation, communication and memory access characteristics which result in varying performance between devices.
On HPC systems a single node may feature a GPU, CPU, and an FPGA or MIC.
This work presents a device independent predictor -- a methodology to use device-independent characteristics of scientific codes to select the optimal accelerator device with regard to execution time or energy expenditure.
<!-- The usefulness of this work is more general, since the trend of having heterogenous nodes is becoming increasingly applicable to general purpose high-performance computing systems, where currently, it is not uncommon for a GPU, a CPU co-processor and an FPGA or MIC to exist on a single node.-->

OpenCL is a suitable programming model for high-performance computing systems.
With wide support from hardware vendors it is a highly portable language -- a single implementation can execute on CPU, GPU, MIC and FPGA alike.


The first focus of this work is to present a comprehensive benchmark suite for OpenCL in the heterogeneous HPC setting: an extended and enhanced version of the OpenDwarfs OpenCL benchmark suite.
Our extensions improve portability and robustness of applications, correctness of results and choice of problem size, and increase diversity through coverage of additional application patterns.
This work manifests in performance measurements on a set 15 devices and over 11 applications.

We next present the Architecture Independent Workload Characterization (AIWC) tool which characterizes OpenCL kernels according to a set of architecture-independent features.
Features are measured by counting target characteristics which are collected during program execution in a simulator.
They are presented as 42 metrics that indicate performance bottlenecks in four categories: parallelism -- how well an algorithm scales in response to core count; compute -- the diversity of instructions; memory -- working memory footprint and entropy measurements which correspond to caching characteristics; and control -- branching and program flow.
The metrics collected are primarily used in the prediction of execution times, but since they are representative of structural characteristics of the underlying program and are free from architectural traits, they can be used in diversity analysis in benchmark suites, identifying program requirements which allows the automatic calculation of theoretical peak performance for a given device and examining the differences in kernels to show the phase-transitional properties of application codes.
We also discuss the design decisions made to collect AIWC features.

Finally, this work culminates in a methodology which uses AIWC features to form a model capable of predicting accelerator execution times.
The model is formed using the random forest algorithm from machine learning.
We use this methodology to predict execution times for a set of 37 computational kernels running on 15 different devices representing a broad range of CPU, GPU and MIC architectures.
The predictions are highly accurate, differing from the measured experimental run-times by an average of only 1.2%.
A previously unencountered code can be instrumented once and the AIWC metrics embedded in the kernel, to allow performance prediction across the full range of modeled devices.
The results suggest that this methodology supports correct selection of the most appropriate device for a previously unencountered code, and is highly relevant to efficiently scheduling codes to the emerging supercomputing systems where nodes are becoming increasingly heterogeneous.

<!--Given the need for more efficient super-computers it is believed that this research is well timed.-->

\pagenumbering{roman}
\setcounter{page}{1}
\newpage

