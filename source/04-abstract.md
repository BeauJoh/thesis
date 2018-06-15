# Abstract {.unnumbered}

OpenCL is an attractive programming model for high-performance computing systems, with wide support from hardware vendors and significant performance portability.
To support efficient scheduling on HPC systems it is necessary to perform accurate performance predictions for OpenCL workloads on varied compute devices, which is challenging due to diverse computation, communication and memory access characteristics which result in varying performance between devices.
This work presents a comprehensive benchmark suite for OpenCL in the heterogenous HPC setting: an extended and enhanced version of the Open-Dwarfs OpenCL benchmark suite.
The extensions improve portability and robustness of applications, correctness of results and choice of problem size, and increase diversity through coverage of additional application patterns.

The Architecture Independent Workload Characterization (AIWC) tool can be used to characterize OpenCL kernels according to a set of architecture-independent features.
This work also discusses the design decisions made to collect AIWC features.
AIWC is a useful tool for benchmark developers since it:

1) provides insights around the inclusion of an application via diversity analysis of the feature-space.
2) measures requirements in terms of FLOPs, memory movement and integer ops of any application kernel -- which allows the automatic calculation of theoretical peak performance for a given device.
3) can be used to examine the phase-transitional properties of application codes -- for instance if the instruction mix changes over time in terms of the balance between floating-point and memory operations.

This work culminates in a methodology where AIWC features are used to form a model capable of predicting accelerator execution times.
I use this methodology to predict execution times for a set of 37 computational kernels running on 15 different devices representing a broad range of CPU, GPU and MIC architectures.
The predictions are highly accurate, differing from the measured experimental run-times by an average of only 1.2%, and correspond to actual execution time mispredictions of 9 $\mu$s to 1 sec according to problem size.
A previously unencountered code can be instrumented once and the AIWC metrics embedded in the kernel, to allow performance prediction across the full range of modeled devices.
The results suggest that this methodology supports correct selection of the most appropriate device for a previously unencountered code, and is highly relevant to efficiently scheduling codes to the emerging supercomputing systems where nodes are becoming increasingly heterogenous.

\pagenumbering{roman}
\setcounter{page}{1}
\newpage

