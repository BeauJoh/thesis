
The development of ODE results in a reliable benchmark suite with multiple problem sizes and high precision measurements.
This allows for reproducible results to be generated quickly, and over a range of heterogenous accelerator devices.
For this thesis 15 devices were used -- and tested on -- to produce a full set of execution times and other performance metrics over all 12 applications and 42 kernels.
The performance metrics allow direct evaluation of devices.

Examining the performance of the benchmark suite over a range of devices allows a direct comparison to be made between these devices on a per application basis.
As a by-product of this comparison, the suitably of OpenCL is shown as a hardware agnostic language.

Separately, the Architecture Independent Workload Characterisation was developed and is capable of identifying the fundamental characteristics of programs free from any specific device.
Architecture Independent Workload Characterisation (AIWC) tool is capable of analysing kernels in order to extract a set of predefined features or characteristics.
The tool can be used in diversity analysis -- which is essential when assembling benchmark suites and justifying the inclusion of an application.
Furthermore, these metrics are used for creating the prediction model to evaluate the performance of OpenCL kernels on different hardware devices and settings.
Such a model is then applied as a prognosis tool to predict the performance of an application for any given platform without additional instrumentation.
This prediction adds information that can be incorporated into existing HPC schedulers and has no run-time overhead -- codes are examined one time by the developer when instrumenting with AIWC and these, in turn, are embedded into the header of each kernel code to be evaluated by the scheduler at the time of scheduling.

The development of AIWC allows codes to be classified according to 
