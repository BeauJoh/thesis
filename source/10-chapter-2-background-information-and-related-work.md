
#Background Information and Related Work

The chapter presents background information, terminology and the related work drawn upon in the rest of this thesis.
It provides a background for readers who might not be familiar with workload characterisation of programs, the associated performance metrics or composition of current HPC systems and how their performance is evaluated.
It begins with an introduction of the Dwarf Taxonomy.
Next, we define accelerators and a provide brief survey regarding their use in supercomputing.
The hardware agnostic programming framework OpenCL is presented.
Finally, this section culminates in a discussion of benchmark suites, applications and where they are incorporated into the dwarf taxonomy.

## The Dwarf Taxonomy

Phil Colella [@colelladefining] identified seven motifs of numerical methods which he thought would be important for the next decade.
Based on this style of analysis, The Berkeley Dwarf Taxonomy [@dwarfmine_2006] was conceived to present the motifs commonplace in HPC.
Initially performed by Asanovic et. al. [@asanovic2006landscape], the Dwarf Taxonomy claims that many applications in parallel computing share patterns of communication and computation.
Applications with similar patterns are defined as being represented by a single Dwarf.
Dwarfs are removed from specific implementations and optimisations.
There are 13 Dwarfs in total.
During the Asanovic et. al. [@asanovic2006landscape] paper, a summary of the diversity of applications is presented, and whilst it is believed that more Dwarfs may be added to this list in the future, all currently encountered scientific codes can be classified as belonging to one or more of these Dwarfs.
For each of the 13 Dwarfs the authors indicate the performance limit -- in other words, whether the dwarf is compute bound, memory latency limited or memory bandwidth limited.
The Dwarfs and their limiting factors are presented in Table \ref{tbl:dwarf-taxonomy}.
Note, the **?** symbol indicates the unknown performance limit at the time of publication.


Table: The Berkeley Dwarfs and their limiting factors. \label{tbl:dwarf-taxonomy}

+-----------------------------------+-------------------------------+
|Dwarf                              |Performance Limit              |
+===================================+===============================+
|Dense Linear Algebra               |Compute                        |
+-----------------------------------+-------------------------------+
|Sparse Linear Algebra              |Memory Bandwidth and Compute   |
+-----------------------------------+-------------------------------+
|Spectral Methods                   |Memory Latency                 |
+-----------------------------------+-------------------------------+
|N-Body Methods                     |Compute                        |
+-----------------------------------+-------------------------------+
|Structured Grid                    |Memory Bandwidth               |
+-----------------------------------+-------------------------------+
|Unstructured Grid                  |Memory Latency                 |
+-----------------------------------+-------------------------------+
|Map Reduce                         |**?**                          |
+-----------------------------------+-------------------------------+
|Combinational Logic                |Memory Bandwidth and Compute   |
+-----------------------------------+-------------------------------+
|Graph Traversal                    |Memory Latency                 |
+-----------------------------------+-------------------------------+
|Dynamic Programming                |Memory Latency                 |
+-----------------------------------+-------------------------------+
|Backtrack and Branch and Bound     |**?**                          |
+-----------------------------------+-------------------------------+
|Graphical Methods                  |**?**                          |
+-----------------------------------+-------------------------------+
|Finite State Machines              |**?**                          |
+-----------------------------------+-------------------------------+


Implementations of applications that are represented by the Dwarf Taxonomy are discussed in the benchmark evaluations presented in Section \ref{sec:chapter2-benchmark-suites}.
Having familiarity with the division of applications and tasks commonly performed on supercomputers positions the use of accelerators for specific Dwarfs.


## Accelerator Architectures in HPC {#sec:chapter2-accelerator-architectures}

Accelerators, in this setting, refer to any form of specialised hardware which may accelerate a given application code.
Fortunately, from The Dwarf Taxonomy previously presented it is envisaged that all applications represented by a dwarf are are better suited to specific types of accelerator.
Accelerators commonly include GPU, FPGA, DSP, ASIC, MIC and CPU devices.
We define accelerators to include all compute devices, including CPUs, since their architecture is well suited to accelerate the computation of specific dwarfs.

Central Processing Units (CPU) have additional circuitry for branch control logic, and generally operate at a high frequency, ensuring this architecture is highly suited to sequential tasks or workloads with many divergent logical comparisons -- corresponding to the finite-state machine, combinational logic, dynamic programming and backtrack branch and bound dwarfs of the Berkeley Dwarf Taxonomy.
Additionally, CPUs are increasingly configured as two separate CPUs but provided on the same System-on-a-Chip (SoC) and strengthens the argument of defining accelerators to include CPUs.
Comprised of two separate micro-architectures, a high-performance CPU -- faster base clock speed with additional hardware for branching -- to support the irregular control and access behaviour of typical workloads; and a smaller CPU -- commonly with a lower base-clock frequency but with many more cores and support for longer vector instructions -- for the highly parallel workloads/tasks common in scientific computing.

The SW26010 and ARM big.LITTLE type processors are modern examples of how CPUs are treated as accelerators to achieve performance on modern supercomputers.
The SW26010 CPU deployed in the Sunway TaihuLight supercomputer, contains a high-performance core known as a Management Processing Element (MPE), and a low-powered processor, the Computer Processing Element (CPE).
The CPE is composed of an 8x8 mesh of cores, supports only user mode, and sports a small 16 KB L1 instruction cache and 64 KB scratch memory.
Both MPE and CPE are both 64-bit Reduced Instruction-Set Computers (RISC) and support 256-bit vector instructions.
This configuration shows the intent of the architecture, that the smaller CPE need be used effectively to achieve good performance [@dongarra2016report], in other words, the host or primary core contributes only a small part of the maximum theoretical FLOPs on modern heterogeneous supercomputers.
.
ARM processors with big.LITTLE and dynamIQ configurations have been proposed to meet the power needs of exascale supercomputers [@padoin2014performance] [@aroca2012towards] [@rajovic2013low] [@keipert2015energy].
big.LITTLE is an heterogeneous configuration of CPU cores on the same die and memory regions.
The big cores have higher clock frequencies and are generally more powerful  than the LITTLE cores, which creates a multi-core processor that suites a dynamic workload more than clock scaling.
Both the SW26010 and big.LITTLE devices, have side cores which need to be carefully handled to achieve high FLOPs, since they accelerate the workloads they are thus defined as accelerators.

Graphics Processing Units (GPU) as the name would suggest, accelerate manipulating computer graphics and image processing and is achieved by having circuit designs to apply the same alterations to many values at once.
This highly parallel structure makes them suitable for applications which involve processing large blocks of data.
Many of the dwarfs of scientific computation are directly suited to GPUs for acceleration, including dense [@volkov2008benchmarking][@tomov2010dense] and sparse linear algebra and N-Body methods.
There has been an active effort to migrate applications from less suited dwarfs, such as, spectral methods [@komatitsch2010high], structured grids [@nicolescu2015structured] and graph traversal [@merrill2012scalable] for GPU acceleration.
Efforts are primarily algorithmic, such as reordering of operations and the padding of shared memory, and have been used with various success on GPU architectures [@springer2011berkeley].
Avoiding bank-conflicts, non-coalesced memory accesses and an increase in the use of private and shared memory are critical to performance of these dwarfs on GPUs.
They are the most common type of accelerator in supercomputer systems.
The recent adoption of the NVIDIA Volta GV100 GPU as the primary accelerator into the Summit and Sierra supercomputers [@markidis2018nvidia] is attributed to their performance [@tomov2010towards] and energy efficiency [@abdelfattah2018analysis] on workloads fundamental to scientific computing.

Many Integrated Core (MIC) architectures are an Intel Corporation specific accelerator.
Xeon Phi formerly known as Knights Landing (KNL) is the last series of the MIC accelerators, and was discontinued in July 2018.
It is similar to a GPU, by having many low frequency in-order cores sharing the same bus however the primary difference being each core is based on conventional CPU x86 architectures.
There are 72 cores with a layout based on a 2D mesh topology -- comprised of 38 tiles, each tile features two CPU cores, and each core contains two Vector Processing Units (VPU). [@sodani2016knights].
A 2D cache-coherent interconnect between tiles is included provide high-bandwidth pathways to match the memory access patterns on the core and mesh layout -- cores on the same tile have a shared 1 MB L2 cache.
Each core supports a 512-bit vector instruction to utilize a large amount of SIMD parallelism.
Dwarfs such as dense and sparse linear algebra are high-intensity and throughput-oriented workloads suited to the Xeon Phi accelerator [@dongarra2015hpc].
The Xeon Phi is the primary accelerator in the Trinity [@rajantrinity] and Cori [@antypas2014cori] supercomputer systems -- currently in the top 10 of the Top500.

Field-Programmable Gate Arrays (FPGA) are accelerators which allows the physical hardware to be reconfigured for any specific task.
They are composed of a high number of logic-gates organised into logic-blocks with fast I/O rates and bi-directional communication between them.
FPGAs are suitable for workloads which require simple operations on very large amounts of data with a fast I/O transfer.
Specifically, they are well suited to accelerating applications from spectral methods dwarf, specifically stream/filter processing on temporal data, and the combinational logic dwarf, which exploit bit-level parallelism to achieve high throughput.
An example of the combinational logic dwarf is in the computing of checksums which is commonly required for network processing and ensuring data archive integrity.
The configurablity of these devices may make them well suited to the characteristics of many dwarfs, however, the compilation or configuring the hardware for an application takes many orders of magnitude longer than any of the other examined accelerator architectures.
Akram et. al.[@akram2018fpga] present a prototype FPGA supercomputer comprised of 5 compute nodes, each with an ARM CPU and Xilinx 7 FPGA.
The benchmark application was over on a Finite Impulse Response Filter -- an application typical to the Spectral Methods Dwarf -- and presents 8.5$\times$ performance over direct computation on the ARM CPU alone.
Unfortunately, energy efficiency or a comparison between GPU accelerators is not presented.
Fujita et. al. [@fujita2018accelerating] present a comparison between a P100 GPU and BittWare A10PL4 FPGA over a Authentic Radiation Transfer scientific application and show that the performance is comparable, however an energy efficiency comparison between these two accelerators is not presented.
Given the increasing need for high-throughput devices from applications in combinational logic and other dwarfs, FPGA devices are likely to be included in future HPC systems.

Application-Specific Integrated Circuit (ASIC) is an integrated circuit designed for a specific task.
In this regard, they are akin to FPGAs without the ability to be reconfigured.
They have been actively used to accelerate the hashing workloads from the combinational logic dwarf for bitcoin mining tasks.
Google's Tensor Processing Units (TPU) are another example of ASICs, and support the TensorFlow [@abadi2016tensorflow] framework. 
TPUs perform convolutions for Machine Learning applications, which largly requires matrix operations and are encapsulated by both the dense and sparse linear algebra dwarfs [@gallopoulos2016parallelism].

Digital Signal Processors (DSP) have their origins in audio processing -- specifically in telephone exchanges and more recently in mobile phones -- where streams of data are constantly arriving and an identical task is needed to be applied.
Audio compression and temporal filtering are examples of the Spectral Methods dwarf and are best suited to the DSP architecture.
DSP cores operate on a separate clock to the host CPU and have circular memory buffers which allow a host device -- using shared memory -- to provide and remove data for processing without ever interrupting the DSP.
Furthermore, Mitra et al. [@mitra2018development] evaluate prototype a nCore Brown-Dwarf system where each node contains an ARM Cortex-A15 host CPU, a single Texas Instruments Keystone II DSP and two Keystone I DSPs.
They compare the performance and energy-efficiency of Level-3 BLAS matrix multiplications and a real-world scientific code for biostructure based drug design against comparisons on conventional x86 based HPC systems with attached accelerators.
They show a Brown-Dwarf node is competitive with contemporary systems for memory-bound computations and show the C66x multi-core DSP is capable of running floating-point intensive HPC application codes.

Research around examining the suitability of ARM CPUs in conjunction with unconventional accelerators such as DSPs is highly active  [@maqbool2015evaluating][@rajovic2014tibidabo1][@jarus2013performance].
Isambard[@feldman_2017_isambard] and Astra[@lacy2018building] systems use the Cavium ThunderX2 CPU accelerator, where each ThunderX2 accelerator consists of 32 high-end ARM cores operating at 2.1 GHz [@mcintoshcomparative].
Separately, Fujitsu's Post-K [@morgan_2016_postk] .
However, currently, only 25 of the Top500 systems are based on ARM technologies.

In general, supercomputer systems are increasing using varied accelerator devices.
A major motivation for this is to reduce energy use; indeed, without significant improvements in energy efficiency, the cost of exascale computing will be prohibitive [@villa2014scaling].
The diversity of accelerators in this space is best shown in a survey of accelerator usage and energy consumption in the worlds leading supercomputers.
The complete results from the TOP500 and Green500 lists [@feldman_2017] were examined, over consecutive years from 2013 to 2018.
Each dataset was taken from the June editions of the yearly listings.

\todo[inline]{add energy usage to plot -- maybe superimposed over the percentage of top500 using accelerators}
\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{analysis/top500_percentage_of_supercomputers_with_accelerators.pdf}
    \caption{The percentage of accelerators in use in the Top500 supercomputers over time.}
    \label{fig:top500-percentage-of-supercomputers-using-accelerators}
\end{figure*}

Figure \ref{fig:top500-percentage-of-supercomputers-using-accelerators} shows steady increase in the use of accelerators in supercomputers.
In 2013 11\% of systems in the TOP500 used accelerators, this increased by roughly 2\% per year.
As of 2018 22\% of the TOP500 use accelerators.

\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{analysis/top10_percentage_of_supercomputers_with_accelerators.pdf}
    \caption{The percentage of accelerators in use in the top 10 ranked of the Top500 supercomputers.}
    \label{fig:top10-percentage-of-supercomputers-using-accelerators}
\end{figure*}

Similarly, the results presented in Figure \ref{fig:top10-percentage-of-supercomputers-using-accelerators} examines the prevalence of accelerator usage in the TOP500 lists, but confined solely to the top 10 most powerful supercomputers of each year.
The finer resolution presented in this figure shows that the most recently updated/installed systems have a much higher reliance on accelerators in order to place amongst these top supercomputers.
By 2013 40\% of these systems used accelerators to secure a spot in the top 10 of the TOP500, this flat-lined till to 2015.
Note, from 2016 the Sunway TaihuLight system was introduced and falls in the top 10, however due to the relience on the CPE side-core to achieve the FLOPs for its rank, the data was adjusted to be listed as containing an accelerator [@dongarra2016report].
\todo{update these numbers with sunway as an accelerator}
As of 2018 the use of accelerators in the top 10 has jumped to 60\%.
Since the percentages of the use of accelerators in the top 10 is much higher than general, in the remainder of the TOP500, we can conclude that the use of accelerators gives an edge to the ranking of these systems.
Still, the general trend of increased use of accelerators throughout all of the TOP500 continues to increase and reinforces the importance of accelerators in this space.

To further investigate this conclusion a further analysis is presented, the emphasis if placed on the reliance of accelerators to secure the place of the list for these accelerator systems.
The percentage of cores in each system that is made up of accelerator / co-processor cores relative to the total number of cores, and is presented in Figures~\ref{top500-ratio-of-cpu-vs-accelerator-cores} and \ref{top10-ratio-of-cpu-vs-accelerator-cores}.

\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{analysis/top500_ratio_of_cpu_vs_accelerator_cores.pdf}
    \caption{Accelerator cores as a proportion of total cores in the top500 supercomputers.}
    \label{top500-ratio-of-cpu-vs-accelerator-cores}
\end{figure*}

\todo[inline]{reliance on CPU vs accelerator cores}

\todo[inline]{accelerators for energy efficiency}

From June 2016 to June 2017, the average energy efficiency of the top 10 of the Green500 supercomputers rose by 2.3x, from 4.8 to 11.1 gigaflops per watt [@feldman_2017].
For many systems, this was made possible by highly energy-efficient Nvidia Tesla P100 GPUs.
In addition to GPUs, future HPC architectures are also likely to include nodes with FPGA, DSP, ASIC and MIC components.
A single node may be heterogeneous, containing multiple different computing devices; moreover, an HPC system may offer nodes of different types.
For example, the Cori system at Lawrence Berkeley National Laboratory comprises 2,388 Cray XC40 nodes with Intel Haswell CPUs, and 9,688 Intel Xeon Phi nodes [@declerck2016cori].
The Summit supercomputer at Oak Ridge National Laboratory is based on the IBM Power9 CPU, which includes both NVLINK [@morgan_2016], a high bandwidth interconnect between Nvidia GPUs; and CAPI, an interconnect to support FPGAs and other accelerators [@morgan_2017].
Promising next-generation architectures include Fujitsu's Post-K [@morgan_2016_postk], and Cray's CS-400, which forms the platform for the Isambard supercomputer [@feldman_2017_isambard].
Both architectures use ARM cores alongside other conventional accelerators, with several Intel Xeon Phi and Nvidia P100 GPUs per node.
The Tianhe-2A uses a Matrix2000 DSP accelerator [@morgan_2017_tianhe]; so will the future system, the Tianhe-3, which is due to be operational in 2020 and will use ARM CPU cores as the primary compute hardware [@feldman_2018].


## The Open Compute Language Setting

OpenCL (Open Compute Language) is a standard that allows computationally intensive codes to be written once and run efficiently on any compliant accelerator device.
OpenCL is supported on a wide range of systems including CPU, GPU, FPGA, DSP and MIC devices.
While it is possible to write application code directly in OpenCL, it may also be used as a base to implement higher-level programming models.
This technique was shown by Mitra et al., [@mitra2014implementation] where an OpenMP runtime was implemented over an OpenCL framework for Texas Instruments Keystone II DSP architecture.
Having a common back-end in the form of OpenCL allows a direct comparison of identical code across this diverse range of architectures.

OpenCL programs comprise of a host and a device side, the program progression is always the same.
The host is responsible for querying the suitable platforms, vendor OpenCL runtime drivers, and establishing a context on the selected devices.
Next, the host sets up memory buffers, compiles a kernel program for each device -- the final compiled device binaries are generated for each specific device instruction set architecture (ISA).

On the device side, the developer code is enqueued for execution.
Device side code is typically small intensive sub-regions of programs and is known as the kernel.
Kernel code is written in a subset of the C programming language.
Special functions exist to determine a thread's id, this can occur via getting a global index in a given dimension directly, with `get_group_id`, or determined using `get_group_id`, `get_local_size` and `get_local_id` in each dimension.

The host side is then notified once the device has completed execution -- this takes the form of either the host waiting on the `clFinish` command or if the host does not the computed results yet, say for an intermediate result on which a second kernel will operate on the same data, a `clFlush` function call.
Once all device execution has completed and the host has been notified the results are transferred back to the host from the device.
Finally, the context established on the device is freed.

The selection of parameters surrounding how work should be partitioned -- such as how many threads to use and how many threads are in a workgroup -- can have a large impact on performance.
One primary reason is that different accelerators benefit from different levels of parallelism, for instance, GPU devices usually need a high degree of arithmetic intensive parallelism to offset the (relatively) narrow I/O pipeline, while CPUs are general purpose and the switching of threads has a greater penalty on performance.
The tuning of such parameters can positively impact performance, in the OpenCL setting by primarily influencing the workgroup size.
In essence, the global work items can be viewed from the data-parallelism perspective.
Global work indicates the number of threads or instances of a kernel to execute in total.
Additionally, these work items can be run in teams -- denoted local work groups.
Each local work group has a given size, and as previously mentioned can be determined on the device side, in the kernel code, with `get_local_id`.
Incorrectly setting the number of local work groups and therefore also the size of each work group can reduce performance however, recent work shows these parameters can be automatically optimised for any accelerator architecture as will be discussed in [Section @sec:chapter2-autotuning].

The OpenCL programming framework is well-suited to such heterogeneous computing environments, as a single OpenCL code may be executed on multiple different device types.
When combined with autotuning, an OpenCL code may exhibit good performance across varied devices. [@spafford2010maestro, @chaimov2014toward, @nugteren2015cltune, @price2017analyzing]
OpenCL has been used for DSP programming since 2012 [@li2012enabling].
Furthermore, Mitra et al. [@mitra2018development] propose a hybrid programming environment that combines OpenMP, OpenCL and MPI to utilize a nCore Brown-Dwarf system where each node contains an ARM Cortex-A15 host CPU, a single Texas Instruments Keystone II DSP and two Keystone I DSPs.
OpenCL codes can be written to be easily linked with auto-tuners -- such as allowing the local work group size being set from the command line or as a macro in the pre-processor, these are set during execution and during compilation respectively.

Kernel compilation flags are an additional tuning argument which affects runtime performance of accelerator specific OpenCL kernel codes.
These flags are set on the host side during the `clBuildProgram` procedure.
Pre-processor macros can also be defined on the kernel side which allows various loop level parallelism constructs to be enabled or disabled.
Mathematical intrinsic options can also be set to disable double floating point precision, and change how denormalised numbers are handled.
Other optimisations include using the strictest aliasing rules, use of the fast fused multiply and add instruction (with reduced precision), ignoring the signedness of floating point zeros and relaxed, finite or unsafe math operations.
These can also be corrected using autotuning for both kernel specific and device specific optimisations.


## Benchmark Suites{#sec:chapter2-benchmark-suites}

Benchmarking forms the basis on which comparisons between languages and environments are made.
Benchmark suites are large sets of benchmark codes used to reliably compare and measure realistic problems under realistic settings.
Our work focuses on benchmarking for device specific performance limitations, for example, by examining the problem sizes where these limitations occur -- this is largely ignored by benchmarking suites with fixed problem sizes.
For these reasons, we introduce the Extended OpenDwarfs benchmark suite in [Chapter @sec:chapter-3-ode] which covers a wider range of application patterns by focusing exclusively on OpenCL using higher-level benchmarks.
Before jumping into this work an evaluation of existing benchmark suites is considered in the remainder of this section.

The NAS parallel benchmarks [@bailey1991parallel] follow a ‘pencil-and-paper‘ approach, specifying the computational problems to be included in the benchmark suite but leaving implementation choices such as language, data structures and algorithms to the user.
The benchmarks include varied kernels and applications which allow a nuanced evaluation of a complete HPC system, however, the unconstrained approach does not readily support direct performance comparison between different hardware accelerators using a single set of codes.

Martineau et al. [@martineau2016performance] collected a suite of benchmarks and three mini-apps to evaluate Clang OpenMP 4.5 support for Nvidia GPUs.
Their focus was on comparison with CUDA; OpenCL was not considered.

Barnes et al. [@barnes2016evaluating] collected a representative set of applications from the current NERSC workload to guide optimization for Knights Landing in the Cori supercomputer.
As it is not always feasible to perform such a detailed performance study of the capabilities of different computational devices for particular applications, the benchmarks described in this paper may give a rough understanding of device performance and limitations.

Rodinia and the original OpenDwarfs benchmark suite focused on collecting a representative set of benchmarks for scientific applications, classified according to dwarfs, with a thorough diversity analysis to justify the addition of each benchmark to the corresponding suite.

The Scalable Heterogeneous Computing benchmark suite (SHOC)[@lopez2015examining], unlike OpenDwarfs and Rodinia, supports multiple nodes using MPI for distributed parallelism.
SHOC supports multiple programming models including OpenCL, CUDA and OpenACC, with benchmarks ranging from targeted tests of particular low-level hardware features to a handful of application kernels.

Sun et al.[@sun2016] propose Hetero-Mark, a Benchmark Suite for CPU-GPU Collaborative Computing, which has five benchmark applications each implemented in the Heterogeneous Compute Compiler (HCC) -- which compiles to OpenCL and HIP which converts CUDA codes to the AMD Radeon Open Compute back-end.
Meanwhile, Chai by Gómez-Luna et al.[@gomez2017chai], offers 15 applications in 7 different implementations with the focus on supporting integrated architectures.

Barnes et al.[@barnes2016evaluating] collected a representative set of applications from the current NERSC workload to guide optimization for Knights Landing in the Cori supercomputer.
As it is not always feasible to perform such a detailed performance study of the capabilities of different computational devices for particular applications, the benchmarks described in this paper may give a rough understanding of device performance and limitations.


### Rodinia


Che et. al [@che2009rodinia] initially proposed a benchmark suite to cover a wide range of parallel communication patterns.
The benchmarks were selected following the Berkeley Dwarf Taxonomy and are from real world high performance computing applications.
The diversity between selected benchmarks was shown by measuring execution times, communications overheads and energy usage of running each benchmark on an NVIDIA GTX 280 GPU and an Intel Core 2 Extreme CPU.
Across the suite: speedups in execution times ranged from 5.5x to 80.8x, communication overheads varied from 2-76% and GPU power consumption overheads ranged from 38-83 Watts, illustrating important architectural differences between the CPU and GPU.
At the time this paper was written the Rodinia Benchmark suite consisted of nine applications; namely, Leukocyte Tracking, Speckle Reducing Anisotropic Diffusion, HotSpot, Back Propagation, Needleman-Wunsch, K-means, Stream Cluster, Breadth-First Search and Similarity Score, but it has since been extended. [@che2010characterization]
This extension features a subset of the dwarfs, namely, Structured Grid, Unstructured Grid, Dynamic Programming, Dense Linear Algebra, MapReduce, and Graph Traversal all of which may be expected to benefit from GPU acceleration.
Diversity analysis was also performed and took the form of a Micro-Architecture independent analysis study.
The MICA framework, discussed in [Section @sec:microarchitecture-independent], was used as the basis of the evaluation and the motivation was to justify each applications inclusion in the benchmark suite by showing deviations between applications in the corresponding kiviat diagrams.
Three separate implementations were developed for each application using CUDA for the GPU, OpenMP for the CPU and OpenCL for both architecture types.
Several implementations caused fragmentation in development, which often resulted in the OpenCL version of each benchmark application being neglected; missing features offered in other implementations and in some instances lacking an implementation of a given application entirely.
For this reason, Rodinia is not a suitable base for an OpenCL benchmark suite, however, we were able to incorporate the dwt2d benchmark into our extended version of the OpenDwarfs  benchmark suite as will be discussed in Chapter 3.
Many of the benchmarks were added from Rodinia into the original OpenDwarfs suite, in our extended evaluation many of the datasets were generated by analyse the original Rodinia source.

### SHOC

The Scalable Heterogeneous Computing benchmark suite SHOC, presented by Danalis et. al. [@danalis2010scalable], offer an alternative benchmark suite and unlike OpenDwarfs and Rodinia, supports multiple nodes using MPI for distributed parallelism.
It also has not been structured into the dwarf taxonomy but rather the benchmarks it encompasses have been categorised according according to two major sets, whether the application performs a stress test role -- which assess the device capabilities --  or acts as a performance test -- which measure host / system performance usually on synthetic kernels.
SHOC supports multiple programming models including OpenCL, CUDA and OpenACC, with benchmarks ranging from targeted tests of particular low-level hardware features to a handful of application kernels.
The variety of language implementations for each benchmark application, was one of the original motivators for its construction.
In this benchmark suite the OpenCL versions of each application have been designed to strongly mirror the CUDA counterparts, unfortunately this results in fixed tuning parameters such as local workgroup size that is well suited to GPU architectures but is not suited to CPU and other accelerator devices.

Since this suite has not been classified according to the dwarf taxonomy and also if the classification were performed, adding more applications would likely need to occur to fully encompass the dwarf taxonomy; the addition of applications is more expensive in SHOC, since it would require implementations for the same application into at least three other languages -- which is not a motivating factor for this thesis.
By focusing on application kernels written exclusively in OpenCL, our enhanced OpenDwarfs benchmark suite is able to cover a wider range of application patterns.


### OpenDwarfs

As with Rodinia, Feng et. al [@feng2012opencl] introduce the OpenDwarfs (OpenCL and the 13 Dwarfs) as an OpenCL implementation of Berkeley’s 13 computational dwarfs of scientific computing.
In this work, the absolute execution times were collected over 11 benchmarks.
In this paper 11 applications were evaluated on a CPU, an Intel Xeon E5405, and three GPUs, a low power AMD HD5450 with 25W TDP, and two high-power GPUs: AMD HD5870 and an Nvidia GT520 with energy footprints of 228 and 238W TDP respectively.
A larger range of dwarfs are covered by OpenDwarfs than Rodinia; however, one dwarf, MapReduce, is still not represented by any application.
Additionally, several dwarfs currently have only one representative application which may not expose the entire set of characteristics of that dwarf.

A potential criticism is that no diversity analysis was performed to justify the inclusion of each application -- however since many applications were inherited from the Rodinia code-base these applications have a proven MICA diversity.
Recently, this work was updated and evaluated on FPGA devices by Krommydas et. al. [@krommydas2016opendwarfs].
Given the focused effort of having all the dwarfs represented, the choice to have one implementation -- and that being OpenCL, and the recent use of the benchmark suite for a new accelerator architecture all result in it being the selected benchmark suite to perform the extension.
These efforts are discussed in Chapter 3.


## Hardware Performance and Scaling

The performance of heterogeneous devices is often evaluated against a theoretical upper-bound.
Computing this limit requires an understanding of a couple of important hardware characteristics.
This sections discusses scaling with respect to clock frequency and core count.
Also included, is a discussion on the impact frequency has on energy consumption.

### Frequency

Changing the clock frequency of a conventional CPU core ultimately change performance results, execution times are impacted but the energy efficiency of the device is also affected.
Choi, Soma and Pedram [@choi2005fine] present an intra-process dynamic voltage and frequency scaling with the goal of minimising energy consumption yet maximising performance by dynamically changing the clock frequency of the CPU.
This is achieved by modelling the on-chip / off-chip ratio which is updated using runtime event monitoring.
Hardware measurements showed that dynamically lowing the clock frequency for memory bound problems up to 70% energy was saved with a 12% performance loss, compute bound workloads 15-60% energy savings were had at a cost of a performance drop of 5-20%.

Meanwhile, Agarwal et. al. [@Agarwal:2000:CRV:339647.339691] show that wire latencies (which correspond to memory movement and chip-to-chip communication) have not matched the increase in the range of clock-frequency.
As such the impact of increasing the clock frequency is having (and will continue to have) less of an impact on computational efficiency.

Recently, Brown [@brown2010toward] discusses how increasing the clock frequency to generate a result faster (known as race-to-idle or race-to-sleep) saves up to 95% of energy if the entire system can be put in a suspended state -- as in embedded and mobile systems.
In 2014, this was validated for hardware used in HPC provided it supports a sleep state.
Albers and Antoniadis [@Albers:2014:RIN:2578852.2556953] present a framework to accurately approximate the energy cost of speed scaling with a sleep state.
In this study, the authors show that the active state of a CPU is comparable to the dynamic energy needed for processing.

### Core count

\todo[inline]{elaborate}
Taylor [@taylor2012dark] surveys the transition of typical homogeneous cores to a potentially dark silicone -- bright future for heterogeneous systems.
This is not because of the lack of scale from increasing cores, indeed Taylor proposes this trend will continue, but from energy concerns of having the utilisation wall[@venkatesh2010conservation].


### Time and Energy -- a non-linear relationship
\todo[inline]{elaborate}
Additionally, there exist applications where the coupling between execution time and energy consumption is non-linear[lively2011energy], and as such, there should be dwarfs wherein this non-linear relationship holds.


## OpenCL Performance

The performance of OpenCL Kernels are lately affected by runtime parameters considering how work is divided, this allocation and partitioning of work changes between devices.
Much of the partitioning can occur automatically using autotuning.
Autotuning and tools and techniques used to measure device performance are summarised in this subsection.
Also discussed, is the common issue of phase shifting and how it relates to measuring OpenCL performance.

### Autotuning{#sec:chapter2-autotuning}

When combined with autotuning, an OpenCL code may exhibit good performance across varied devices.
Every application presented in the Rodinia Benchmark Suite \[sec:rodinia\] requires a local workgroup to be passed.
In the OpenDwarfs set of benchmarks 9 out of 14 allow for local workgroup tuning.
Therefore, given a majority of OpenCL programs use local workgroup tuning, serious considerations need be given regarding how to ensure an accurate depiction of execution times for all accelerators is given.
Older literature on the subject also suggests autotuning will play an increasingly important role, in determining accelerator centric optimisations.
Tasks such as compiler optimisations and kernel runtime tuning parameters are well suited to auto-tuners without requiring an exhaustive search in this search space.

This has been manifested in many auto-tuning libraries that use machine learning.
Spafford et al. [@spafford2010maestro], Chaimov et al. [@chaimov2014toward] and Nugteren and Codreanu [@nugteren2015cltune] all propose open source libraries capable of performing autotuning of dynamic execution parameters in OpenCL kernels.
Additionally, Price and McIntosh-Smith [@price2017analyzing] have demonstrated high performance using a general purpose autotuning library [@ansel:pact:2014], for three applications across twelve devices.

One auto-tuning library of particular interest is OpenTuner [@ansel:pact:2014] since it has already been employed by Price and McIntosh-Smith [@price2017analyzing] to improve the performance of OpenCL applications.
The OpenTuner library requires the search space to be defined in order to effect the runtime performance of the application.
These take the forms of command line of compile time arguments -- and are known as the configuration parameter when performing application execution.
Next, machine learning techniques are used employing a black box mechanism to effectively search for the optimal configuration parameter arguments in the search space.
Measurements are collected per run effectively updating a cost function.
Both the objective of the search and the cost function are entirely flexible, since this framework takes the form of a modular python library.

In the Price [@price2017analyzing] survey, OpenCL kernels are optimised across 9 current GPUs, 5 Nvidia and 4 AMD devices, and 3 high-end Intel CPUs.
The experiment was performed over 3 benchmarks, the Jacobi Iterative Method, a Bilateral Filtering algorithm and BUDE -- A general purpose molecular docking program.
Presented results show the inefficiencies when auto-tuning for one target device and then execute this optimised program on the other systems.
The usefulness of this multi-objective auto-tuning technique is demonstrated and shows that it is a useful tool to generate performance portable OpenCL kernels.
Additionally the literature shows that over-optimisation hurts performance portability.


### Phase-Shifting

Phase is defined as a set of intervals (or slices in time) within a programs execution that has similar behaviour.
Therefore, the term phase-shifting refers to change of the execution of a program with temporal adjacency such that the program experiences time-varying effects.
Sherwood  et. al. [@sherwood2003discovering] observe that common system design and optimisation focus heavily on the assume average system behaviour.
They propose however instead programs should be modelled and optimised for phase-based program behaviour.
The approach outlined states that phase-behaviour can be profiled quickly using block vector [@sherwood2002automatically] profiles (a vector of per element counts, where each element is the number of times a code block has been entered over a given interval) and off-line classification.

An assumption in the literature is that OpenCL kernels are largely unaffected by program phase-shift.
Rather, the program as a whole will doubtlessly experience phase-shifts, compiling an OpenCL kernel code which is an active component of all OpenCL programs will heavily utilise the host CPU device, and when a kernel is executed and the host waits for the device to finish, CPU utilisation is low.
The kernel in execution itself will experience very little differences in phases since by their very nature OpenCL kernels are designed small and compartmentalised sections of computation.
Such that, if a kernel executed on a particular accelerator device is memory bound, it will consistently be memory bound.
If the accelerator experiences consistent stalls on repeated branch mispredictions, this is consistent throughout the kernels entire execution.

###Formal measurements{#sec:formal-measurements}

Many studies presented in this thesis use tools developed by others in order to perform the necessary measurements.
Time measurements of OpenCL kernels have primarily used LibSciBench as the default performance measurement tool.
It allows high precision timing events to be collected for statistical analysis [@hoefler2015scientific].
Additionally, it offers a high resolution timer in order to measure short running kernel codes, reported with one cycle resolution and roughly 6 ns of overhead.
Throughout Chapter 3 LibSciBench was intensively used to record timings in conjunction with hardware events, which it collects via PAPI [@mucci1999papi] counters.


## Offline Ahead-of-Time Analysis

The term offline analysis, in this setting, is defined as the detailed examination of the structure of code and that it requires the entire data set is given in advance.
Ahead-of-time indicates that this analysis be done before the program is executed.
The combination of theses two terms is directly applicable to OpenCL SPIR codes, which is based on LLVM, since LLVM is well suited to performing ahead-of-time optimised native code generation [@lattner2004llvm].
Additionally, since SPIR is hardware agnostic/ISA-independent the patterns of computation and communication as shown in the dwarf taxonomy it can be done once the OpenCL source is converted to SPIR and the dwarf represented by the kernel will always be the same.
Therefore, analysis such as the classification of which dwarf a new code can be identified, can be performed before any actual device execution is performed.
Additionally, these classification and other analysis metrics can be embedded into the SPIR code as a comment in the header, which in turn can be used by a scheduler to determine which device the kernel should be executed.

Closely related to the work performed in this thesis was independently performed by Muralidharan et. al. [@muralidharan2015semi].
Wherein, they use offline ahead-of-time analysis with Oclgrind to collect an instruction histogram of each OpenCL kernel execution in order to generate an estimate of the roofline model analysis for each given accelerator.
The resultant tool-flow methodology is used to analyse and track the performance over 3 distinct heterogeneous platforms, and results in a metric to characterise performance.
The basis of our work on AIWC is built on offline ahead-of-time analysis techniques and is presented in Chapter 4.

##Program Diversity Analysis and characterization {#sec:chapter2-program-diversity-analysis}

Program Diversity Analysis has occurred historically to justify the inclusion of an application into a benchmark suite for many years, Principal Component Analysis (PCA) has been used to demonstrate program diversity by others[@blackburn2006dacapo][@hara2009proposal][@phansalkar2007analysis].
Often this work, is manually performed by those focused on assembling the benchmark suites.
Indeed, much of the motivation for curating OpenCL applications in Rodinia [@che2009rodinia], OpenDwarfs [@feng2012opencl] and SHOC [@danalis2010scalable] was to have real-world scientific problems that represented regular workloads of HPC and SC systems.
Determining the suitability of an application regarding these characterised metrics has been evaluated by others.
This Section examines these combined efforts in characterising workloads that are less sensitive to the architectures on which they are executed, and concludes with how these characterisation techniques have been used when assembling benchmark suites.

The use of a vector-space or feature-space in order to classify the characteristics of parallel programs was performed by Meajil, El-Ghazawi and Sterling in 1997 [@meajil1997architecture].
The target of this work was to determine the major factors in modelling performance between parallel computer architectures in an architecture-independent manner.
The remainder of this section introduces more recent developments in using a vector-space to characterise applications.

##Microarchitecture-independent workload characterization {#sec:microarchitecture-independent}

Hoste and Eeckout [@hoste2007microarchitecture] show that although conventional microarchitecture-dependent characteristics are useful in locating performance bottlenecks [@ganesan2008performance,@prakash2008performance], they are misleading when used as a basis on which to differentiate benchmark applications.
Microarchitecture-independent workload characterization and the associated analysis tool, known as MICA, was proposed to collect metrics to characterize an application independent of particular microarchitectural characteristics.
Architecture-dependent characteristics typically include instructions per cycle (IPC) and miss rates -- cache, branch misprediction and translation look-aside buffer (TLB) -- and are collected from hardware performance counter results, typically PAPI.
These characteristics fail to distinguish between inherent program behaviour and its mapping to specific hardware features, ignoring critical differences between architectures such as pipeline depth and cache size.
The MICA framework collects independent features including instruction mix, instruction-level parallelism (ILP), register traffic, working-set size, data stream strides and branch predictability.
These feature results are collected using the Pin [@luk2005pin] binary instrumentation tool.
In total 47 microarchitecture-independent metrics are used to characterize an application code.
To simplify analysis and understanding of the data, the authors combine principal component analysis with a genetic algorithm to select eight metrics which account for approximately 80% of the variance in the data set.

A caveat in the MICA approach is that the results presented are not ISA-independent nor independent from differences in compilers.
Additionally, since the metrics collected rely heavily on Pin instrumentation, characterization of multi-threaded workloads or accelerators are not supported.
As such, it is unsuited to conventional supercomputing workloads which make heavy use of parallelism and accelerators.


### Architecture Independent Workload Characterization{#sec:chapter2-isa-independent}

Recently, Shao and Brooks [@shao2013isa] have since extended the generality of the MICA to be ISA independent.
The primary motivation for this work was in evaluating the suitability of benchmark suites when targeted on general purpose accelerator platforms.
The proposed framework briefly evaluates eleven SPEC benchmarks and examines 5 ISA-independent features/metrics.
Namely, number of opcodes (e.g., add, mul), the value of branch entropy -- a measure of the randomness of branch behaviour, the value of memory entropy -- a metric based on the lack of memory locality when examining accesses, the unique number of static instructions, and the unique number of data addresses.

Related to the paper, Shao also presents a proof of concept implementation (WIICA) which uses an LLVM IR Trace Profiler to generate an execution trace, from which a python script collects the ISA independent metrics.
Any results gleaned from WIICA are easily reproducible, the execution trace is generated by manually selecting regions of code built from the LLVM IR Trace Profiler.
Unfortunately, use of the tool is non-trivial given the complexity of the toolchain and the nature of dependencies (LLVM 3.4 and Clang 3.4).
Additionally, WIICA operates on `C` and `C++` code, which cannot be executed directly on any accelerator device aside from the CPU.
Our work on Architecture Independent Workload Characterisation or known as (AIWC) is presented in Chapter 4, and extends Shao's work to the broader OpenCL setting to collect architecture independent metrics from a hardware-agnostic language -- OpenCL.
Additional metrics, such as Instructions To Barrier (ITB), Vectorization (SIMD) indicators and Instructions Per Operand (SIMT) were also determined and added by us in order to perform a similar analysis for concurrent and accelerator workloads.

AIWC relies on the selection of the instruction set architecture (ISA)-independent features determined by Shao and Brooks [@shao2013isa], which in turn builds on earlier work in microarchitecture-independent workload characterization discussed in [Section @sec:microarchitecture-independent].

The branch entropy measure used by Shao and Brooks [@shao2013isa] was initially proposed by Yokota [@yokota2007introducing] and uses Shannon's information entropy to determine a score of Branch History Entropy.
De Pestel, Eyerman and Eeckhout [@depestel2017linear] proposed an alternative metric, average linear branch entropy metric, to allow accurate prediction of miss rates across a range of branch predictors.
As their metric is more suitable for architecture-independent studies, we adopt it for our work on AIWC.

Caparrós Cabezas and Stanley-Marbell [@CaparrosCabezas:2011:PDM:1989493.1989506] present a framework for characterizing instruction and thread-level parallelism, thread parallelism, and data movement, based on cross-compilation to a MIPS-IV simulator of an ideal machine with perfect caches and branch prediction and unlimited functional units.
Instruction-level and thread-level parallelism are identified through analysis of data dependencies between instructions and basic blocks.
The current version of AIWC does not perform dependency analysis for characterizing parallelism, however, we hope to include such metrics in future versions.

### Using workload characterization for diversity analysis in the benchmark suites

In contrast to our proposed multidimensional workload characterization, models such as Roofline [@williams2009roofline] and Execution-Cache-Memory [@hager2013exploring] seek to characterize an application based on one or two limiting factors such as memory bandwidth.
The advantage of these approaches is the simplicity of analysis and interpretation.
We view these models as capturing a 'principal component' of a more complex performance space; we claim that by allowing the capture of additional dimensions, AIWC supports performance prediction for a greater range of applications.


\todo[inline]{summarise this}https://www.hindawi.com/journals/sp/2015/859491/

<!--
* existing benchmarks have performed characterisation on applications in the past, this has historically targeted for diversity between applications in order to justify inclusion into a benchmark suite
* Rodinia used MICA for the diversity analysis framework
* OpenDwarfs used MICA
-->

Several benchmarks have performed characterisation of applications in the past, this has been primarily, at least historically motivated, for diversity analysis to justify the inclusion of an application into a benchmark suite.
Rodinia used MICA as the diversity analysis framework.
The OpenDwarfs benchmark suite have applications which have been manually classified as dwarfs and any characterisation into this taxonomy is based largely intuition.
Some of the shared applications ported from the Rodinia Benchmark suite cluster microarchitecture-dependent characteristics of applications into dwarfs.
Alas, the approach has the same limitations as those presented in [Section @sec:microarchitecture-independent].

<!--
\todo[inline]{we will do the verification?}
-->

For this reason Chapter 4 of this thesis apart from extending the OpenDwarfs Benchmark suite also adds formal verification of the diversity characterisation.
To some extent Chapter 5 does this even more formally by generating and clustering the feature-space of all applications grouped as dwarfs.
The evaluation on the feature-space is critical to the inclusion of particular extended OpenDwarfs applications and is performed in Chapter 4.

##Oclgrind: Debugging OpenCL kernels via simulation{#sec:oclgrind}


Oclgrind is an OpenCL device simulator developed by Price and McIntosh-Smith [@price:15] capable of performing simulated kernel execution.
It operates on a restricted LLVM IR known as Standard Portable Intermediate Representation (SPIR) [@kessenich2015], thereby simulating OpenCL kernel code in a hardware agnostic manner.
This architecture independence allows the tool to uncover many portability issues when migrating OpenCL code between devices.
Additionally, Oclgrind comes with a set of tools to detect runtime API errors, race conditions and invalid memory accesses, and generate instruction histograms.
AIWC is added as a tool to Oclgrind and leverages its ability to simulate OpenCL device execution using LLVM IR codes.


##Schedulers and Predicting the most Appropriate Accelerator

Predicting the performance of a particular application on a given device is challenging due to complex interactions between the computational requirements of the code and the capabilities of the target device.
Certain classes of application are better suited to a certain type of accelerator [@che2008accelerating], and choosing the wrong device results in slower and more energy-intensive computation [@yildirim2012single].
Thus accurate performance prediction is critical to making optimal scheduling decisions in a heterogeneous supercomputing environment.

Lyerly [@lyerly2014automatic] demonstrates by executing a subset of applications from OpenDwarfs it becomes apparent that not one accelerator has the fastest execution time for all benchmarks.
This contribution focuses on developing a scheduler to delegate the most appropriate accelerator for a given program.
This was achieved by developing a partitioning tool to separate computationally intensive OpenMP regions from C, extracting to and building a predictive model based on past history of the programs executing on the accelerators.
We broaden this analysis by claiming that all benchmarks encompassing a dwarf will perform optimally on one accelerator type, but identify that one type of accelerator is non-optimal for all dwarfs.

Hoste et. al. [@hoste2006performance] show that the prediction of performance can be based on inherent program similarity.
In particular, they show that the metrics collected from a program executing on a particular instruction set architecture (ISA) with a specific compiler offers a relatively accurate characterization of workload for the same application on a totally different micro-architecture.
[Che et. al. @che2009rodinia] broadens this finding with an assumption that performing analysis on a single threaded CPU version of a benchmark application maintains the underlying set of instructions and the composition of the application.

\todo[inline]{summarise this}https://www.hindawi.com/journals/sp/2015/859491/

Therefore, it is intuitive that the composition of a program collected using a simulator (such as Oclgrind discussed in [Section @sec:oclgrind], which operates on the most common intermediate form for the OpenCL runtime) regardless of accelerator to which it is ultimately mapped, offers a more accurate architecture agnostic set of metrics around an applications workload.
This, in turn, can be used as a basis for performance prediction on general accelerators.

##Predictions and Modelling

Augonnet et al. [@augonnet2010data] propose a task scheduling framework for efficiently issuing work between multiple heterogeneous accelerators on a per-node basis.
They focus on the dynamic scheduling of tasks while automating data transfers between processing units to better utilise GPU-based HPC systems.
Much of this work is placed on evaluating the scaling of two applications over multiple nodes -- each of which are comprised of many GPUs.
Unfortunately, the presented methodology requires code to be rewritten using their MPI-like library.
OpenCL, by comparison, has been in use since 2008 and supports heterogeneous execution on most accelerator devices.
The algorithms presented to automate data movement should be reused for scheduling of OpenCL kernels to heterogeneous accelerator systems.

Existing works, [@topcuoglu1999task], [@bajaj2004improving], [@xiaoyong2011novel] and [@sinnen2004list], have addressed heterogeneous distributed system scheduling and in particular the use of Directed Acyclic Graphs to track dependencies of high priority tasks.
Provided the parallelism of each dependency is expressed as OpenCL kernels, the model proposed here can be used to improve each of these scheduler algorithms by providing accurate estimates of execution time for each task for each potential accelerator on which the computation could be performed.

One such approach uses partial execution, as introduced by Yang et al. [@yang2005cross] enables low-cost performance estimates over a wide range of execution platforms.
Here a short portion of a parallel code is executed and, since parallel codes are iterative behave predictably after the initial startup portion.
An important restriction for this approach is it requires execution on each of the accelerators for a given code, which may be complicated to achieve using common HPC scheduling systems.

An alternative performance prediction approach is given by Carrington et al. [@carrington2006performance].
Their solution generates two separate models each requiring two fundamental components: firstly, a machine profile of each system generated by running micro-benchmarks to probe simple performance attributes of each machine; and secondly, application signatures generated by instrumented runs which measure block information such as floating-point utilization and load/store unit usage of an application.
In their method, no training takes place and the micro-benchmarks were developed with CPU memory hierarchy in mind, thus it is unsuited to a broader range of accelerator devices.
There are also many components and tools in use, for instance, network traffic is interpreted separately and requires the communication model to be developed from a different set of network performance capabilities, which needs more micro-benchmarks.

\todo[inline]{Summarise this work!}
https://ieeexplore.ieee.org/abstract/document/6714232/

\todo[inline]{Summarise this :(}http://faculty.engineering.asu.edu/carolewu/wp-content/uploads/2012/12/Lee_iiswc2017_final.pdf

\todo[inline]{Summarise this :(}http://inf-server.inf.uth.gr/~mispyrou/files/Spyrou_Michalis_presentation.pdf

\todo[inline]{Summarise this :(} https://tigerprints.clemson.edu/cgi/viewcontent.cgi?article=3760&context=all_theses

http://users.ece.utexas.edu/~derek/Papers/HPCA2015_GPUPowerModel.pdf

https://dl.acm.org/citation.cfm?id=2812722

http://www.cs.virginia.edu/~skadron/Papers/benchfriend_author_version.pdf

http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.298.3365&rep=rep1&type=pdf
