#The Dwarf Accelerator Mapping

This chapter presents an extension of an existing benchmark suite -- OpenDwarfs.
The extension focuses on adding additional benchmarks to better represent each Dwarf along with supporting a range of 4 problem sizes for each application.
The rationale for the latter is to survey the range of applications over a diverse set of HPC accelerators across increasing amounts of work, which allows for a deeper analysis of the memory subsystem on each of these devices.
The corresponding analysis directly addresses the sub-question around: *Does problem size affect the optimality of a dwarf and its suitability for an accelerator type?*

Next, the results are grouped according to dwarf instead of as independent results.
Analysis of these dwarf groups shows that:

* when focusing on energy analysis, certain dwarfs have results where energy is uncorrelated to execution time,
* particular accelerator types do perform best under all applications encompassing a dwarf,
* and that all dwarfs are not suited to one type of accelerator -- for instance GPU type accelerators are unsuited to the combinational-logic dwarf.


##Experimental Evaluation

### Enhancing the OpenDwarfs Benchmark Suite

Both Rodinia and the original OpenDwarfs benchmark suite focused on collecting a representative benchmarks for scientific applications, classified according to dwarfs, with a thorough diversity analysis to justify the addition of each benchmark to the corresponding suite.

We aim to extend these efforts to achieve a full representation of each dwarf, both by integrating other benchmark suites and adding custom kernels.
At the same time, we hope to improve portability between devices, interpretability and flexibility of configuration including problem sizes.

For the Spectral Methods dwarf, the original OpenDwarfs version of the FFT benchmark was complex, with several code paths that were not executed for the default problem size, and returned incorrect results or failures on some combinations of platforms and problem sizes we tested.
We replaced it with a simpler high-performance FFT benchmark created by Eric Bainville~\cite{bainville2010fft}, which worked correctly in all our tests.
We have also added a 2-D discrete wavelet transform from Rodinia, and we plan to add a continuous wavelet transform code.

As problem size can profoundly affect performance on accelerator systems~\cite{marjanovic2016hpc}, we enhanced configurability so that each benchmark could be run for a wide range of problem sizes.

Previous work[@johnston2017embedded] has shown that energy consumption of accelerator devices, at least in the embedded space and on compute-bound applications, is strongly correlated with execution time.
Extending this investigation of energy usage to communication-bound and memory-bound problems is essential, since many scientific codes targeted for HPC and supercomputing systems have these characteristics.
Additionally, given the candidate accelerators are proposed as future components on such systems, an evaluation of energy consumption on a wide range of accelerators is essential.
To this end, LibSciBench (a performance measurement tool which allows high precision timing events to be collected for statistical analysis), complete with PAPI counters has been added to all of the applications in the OpenDwarfs Benchmark Suite.
Through PAPI modules such as RAPL and NVML, LibSciBench also supports energy measurements, for which we report preliminary results in this paper.

###Experimental Setup

####Hardware

Table: Hardware used in all experiments. \label{tbl:hardware}

+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+
|Name            | Vendor   | Type  | Series    | Core Count     | Frequency min/max/turbo (MHz) | Cache L1/L2/L3 (KiB) | TDP (W) | Launch Date |
+================+==========+=======+===========+================+===============================+======================+=========+=============+
|Xeon E5-2697 v2 | Intel    | CPU   |Ivy Bridge | 24             |1200/2700/3500                 | 32/256/30720         | 130     | Q3 2013     |
+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+
|i7-6700K        | Intel    | CPU   |Skylake    | 8              | 800/4000/4300                 | 32/256/8192          | 91      | Q3 2015     |
+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+
|Titan X         | Nvidia   | GPU   | Pascal    | 3584           | 1417/1531/NA                  | 48/2048/NA           | 250     | Q3 2016     |
+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+
|GTX1080         | Nvidia   | GPU   | Pascal    | 2560           | 1607/1733/NA                  | 48/2048/NA           | 180     | Q2 2016     |
+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+
|GTX1080Ti       | Nvidia   | GPU   | Pascal    | 3584           | 1480/1582/NA                  | 48/2048/NA           | 250     | Q1 2017     |
+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+
|K20m            | Nvidia   | GPU   | Kepler    | 2496           | 706/?/NA                      | 64/1536/NA           | 225     | Q4 2012     |
+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+
|K40m            | Nvidia   | GPU   | Kepler    | 2880           | 745/875/NA                    | 64/1536/NA           | 235     | Q4 2013     |
+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+
|Xeon Phi 7210   | Intel    | MIC   | KNL       | 256            | 1300/1500/NA                  | 32/1024/NA           | 215     | Q2 2016     |
+----------------+----------+-------+-----------+----------------+-------------------------------+----------------------+---------+-------------+


The experiments were conducted on eight hardware platforms and are presented in Table \ref{tbl:hardware}.
Two of these systems are Intel CPU architectures, five are current Nvidia GPUs and one is a MIC (Intel Knights Landing Xeon Phi).
The L1 cache size should be read as having both an instruction size cache and a data cache size of equal values as those displayed.
For Nvidia GPUs, the L2 cache size reported is the size per SM.
For the Intel CPUs, hyper-threading was enabled and the frequency governor was set to `performance`.
Regarding core counts, all Intel CPU core counts presented are Hyper-Threaded cores [@marr2002hyper], resulting in 2 hardware threads per core, all Nvidia devices have the core count presented as CUDA cores, and in the Knights Landing MIC device each physical core has 4 hardware threads per core.


####Software
OpenCL version 1.2 was used for all experiments.
On the CPUs we used the Intel OpenCL driver version 6.3, provided in 16.1.1 and the 2016-R3 opencl-sdk release.
On the GPU we used the Nvidia OpenCL driver version 375.66, provided as part of CUDA 8.0.61.

The Knights Landing (KNL) architecture used the same OpenCL driver as the Intel CPU platforms, however, the 2018-R1 release of the Intel compiler was used.
This was required to compile for the architecture natively on the host.
Additionally, due to Intel removing support for OpenCL on the KNL architecture, some additional compiler flags were required.
Unfortunately, as Intel has removed support for AVX2 vectorization (using the `-xMIC-AVX512` flag), vector instructions use only 256-bit registers instead of the wider 512-bit registers available on KNL.
This means that floating-point performance on KNL is limited to half the theoretical peak.

GCC version 5.4.0 with GLIBC 2.23 was used for the Skylake i7 and GTX 1080,  
GCC version 4.8.5 with GLIBC 2.23 was used on the remaining platforms.
OS Ubuntu Linux 16.04.4 with kernel version 4.4.0 was used for the Skylake CPU and GTX 1080 GPU, Red Hat 4.8.5-11 with kernel version 3.10.0 was used on the other platform.

As OpenDwarfs has no stable release version it was extended from the last commit by the maintainer on the Feb 26, 2016.~\cite{opendwarfs2017base}
LibSciBench version 0.2.2 was used for all performance measurements.

###Measurements

LibSciBench is a performance measurement tool which allows high precision timing events to be collected for statistical analysis[@hoefler2015scientific].
It offers a high resolution timer in order to measure short running kernel codes, reported with one cycle resolution and roughly \SI{6}{\nano\second} of overhead.
LibSciBench was used to record timings in conjunction with hardware events, which it collects via PAPI~\cite{mucci1999papi} counters.

The OpenDwarfs benchmarks have been modified across all the applications by inserting library calls to LibSciBench to record timings and PAPI events for the three main components of application time: kernel execution, host setup and memory transfer operations.
To help understand the timings, the following hardware counters were also collected:

* item total instructions and IPC (Instructions Per Cycle);
* item L1 and L2 data cache misses;
* item total L3 cache events in the form of request rate (requests/instructions) miss rate (misses/instructions) and miss ratio (misses/requests)
* item data TLB (Translation Look-aside Buffer) miss rate (misses/instructions); and
* item branch instructions and branch mispredictions.

A sample of 50 iterations was collected for each measurement.
Only the kernel execution times/energy are presented in the final results.

Energy measurements were taken on Intel platforms using the Running Average Power Limit (RAPL) PAPI module.
Similarly, a PAPI module was used in conjunction with the Nvidia Management Library (NVML) to measure the energy usage on Nvidia GPUs.

####Setting Sizes

For each application, 4 different problem sizes were selected, namely **tiny**, **small**, **medium** and **large**.
These problem sizes are based on the memory hierarchy of the Skylake CPU.
Specifically, **tiny** should just fit within L1 cache, on the Skylake this corresponds to \SI{32}{\kibi\byte} of data cache, **small** should fit within the \SI{256}{\kibi\byte} L2 data cache, **medium** should fit within \SI{8192}{\kibi\byte} of the L3 cache, and **large** must be much larger than \SI{8192}{\kibi\byte} to avoid caching and operate out of main memory.
This was verified using the `lscpu` Linux tool.

For this study, problem sizes were not customized to the memory hierarchy of each platform, since the CPU is the most sensitive to cache performance.
Also, note for these CPU systems the L1 and L2 cache sizes are identical, and since we ensure that L3 is at least $4\times$ larger than L3 for the largest spill over event, we are guaranteed to have L3 cache misses for the **large** problem size.

Caching performance was measured using PAPI counters.
On the Skylake L1 and L2 data cache miss rates were counted using the `PAPI\_L1\_DCM` and `PAPI\_L2\_DCM` counters.
For L3 miss events, only the total cache counter event (`PAPI\_L3\_TCM`) was available.
The final values presented as miss results are presented as a percentage, and were determined using the number of misses counted divided by the total instructions (`\tt PAPI\_TOT\_INS`).

The methodology to determine the appropriate size parameters is demonstrated on the k-means benchmark.
K-means is an iterative algorithm which groups a set of points into clusters, such that each point is closer to the centroid of its assigned cluster than to the centroid of any other cluster.
Each step of the algorithm assigns each point to the cluster with the closest centroid, then relocates each cluster centroid to the mean of all points within the cluster.
Execution terminates when no clusters change size between iterations.
Starting positions for the centroids are determined randomly.
The OpenDwarfs benchmark previously required the object features to be read from a previously generated file.
We extended the benchmark to support generation of a random distribution of points.
This was done to more fairly evaluate cache performance, since repeated runs of clustering on the same feature space (loaded from file) would deterministically generate similar caching performance.
The same number of clusters is fixed, with the minimum and maximum cluster locations being returned both set to 5.

Given a fixed number of clusters, the parameters that may be used to select a problem size are the number of points $P_n$, and the dimensionality or number of features per point $F_n$.
In the kernel for k-means there are 3 large one dimensional arrays passed to the device, namely **feature**, **cluster** and **membership**.
**feature** is the array which stores the unclustered feature space, it is of size $P_n \times F_n \times \text{sizeof}\left(\text{float}\right)$.
Each feature is represented by a 32-bit floating point number.
**cluster** is the working and output array to store the intermediately clustered points, it is of size $C_n \times F_n \times \text{sizeof}\left(\text{float}\right)$, where $C_n$ is the number of clusters.
**membership** is an array indicating whether each point has changed to a new cluster in each iteration of the algorithm, it is of size $P_n \times \text{sizeof}\left(\text{int}\right)$, where $\text{sizeof}\left(\text{int}\right)$ is the number of bytes to represent an integer value.
Thereby the working kernel memory, in KiB, is:
\begin{equation}
    \frac{\text{size}\left(\textbf{feature}\right)+\text{size}\left(\textbf{membership}\right)+\text{size}\left(\textbf{cluster}\right)}{1024}
    \label{eq:kmeans_size}
\end{equation}

Using this equation, we can determine the largest problem size that will fit in each level of cache.
The tiny problem size is defined to have 256 points and 30 features; from Equation~\ref{eq:kmeans_size} the total size of the main arrays is \SI{31.5}{\kibi\byte}, slightly smaller than the \SI{32}{\kibi\byte} L1 cache.
The number of points is increased for each larger problem size to ensure that the main arrays fit within the lower levels of the cache hierarchy, measuring the total execution time and respective caching events.
The **tiny**, **small** and **medium** problem sizes in the first row of Table~\ref{tab:problem_sizes} correspond to L1, L2 and L3 cache respectively.
The **large** problem size is at least four times the size of the last-level cache -- in the case of the Skylake, at least \SI{32}{\mebi\byte} -- to ensure that data are transferred between main memory and cache.

\todo[inline]{insert the rest of the preliminary paper}

##Sensibly Grouping The Data

To make additional sense of the data when the results are reinterpreted according to dwarf and where each application fits in the dwarf taxonomy additional information can be gleaned.

##Evaluation - Dwarfing The Accelerator Selection Problem

From this analysis we see that Prepositions 1 and 2 from the beginning of the chapter has been met.

##The impact of Scale -- An analysis of clock frequency on accelerator selection

This section presents an analysis of clock frequency on the CPU architectures.
Of particular interest, is whether CPU devices are so susceptible to clock frequency that even the dwarfs on which that type of accelerator constantly performs best, lowering the clock frequency causes it to suffer badly enough to not be in pole position.

\todo[inline]{this study should be interesting! and easy}

##The Impact of Tuning

This Section presents an evaluation of the impact of tuning parameters, in particular the variability of the results introduced from autotuning.
Here, the optimal input parameters as determined from the opentuner library are listed per device and for each application.
Next the 

