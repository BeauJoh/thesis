# Extending the OpenDwarfs Benchmark Suite {#sec:chapter-3-ode}


The purpose of this chapter is to outline the development of a testbed that can be used to evaluate approaches to workload characterization and device performance prediction that are proposed in later chapters.
Key characteristics of the testbed are that it should:

1. comprise compute-intensive kernels that are representative of real scientific application codes;
1. support multiple devices;
2. support multiple problem sizes so it can be applied to embedded systems as well as top end scientific processors; and
3. span as many of the dwarfs as possible.

In the related work, [Section @sec:chapter2-benchmark-suites], three potential benchmark suites were considered for the testbed: SHOC [@danalis2010scalable], Rodinia [@che2009rodinia] and OpenDwarfs [@feng2012opencl].
SHOC is focused on microbenchmarks rather than complete kernels as required here.
Rodinia, while focused on complete kernels, is primarily developed as a benchmark suite to compare languages and does not cover all dwarfs.
OpenDwarfs has the widest coverage and is the best candidate for our purposes.
The problems with OpenDwarfs is that the current release:

* Includes architecture specific optimisations in many of the benchmarks, which impact the functionality when executed on other accelerators and often result in crashes.
* Has several parameters fixed, which limits the performance portability on other devices.
* Does not currently support multiple problem sizes, which impacts benchmark performance on accelerators with a memory hierarchy.

In this chapter, we show enhancements made to OpenDwarfs to remedy these issues; and present the Extended OpenDwarfs benchmark suite (EOD) to provide a testbed of representative codes required for the bulk of this thesis.
The benchmarks and the associated measurements of execution time presented in this chapter will be later used for workload characterization, performance prediction and ultimately scheduling, but these sophisticated studies first need simple empirical data.
First, we review the existing OpenDwarfs Benchmark Suite, we then discuss our enhancements.
The experimental setup, methodology and results are then reported concluding with a discussion of future work.
<!--However, methodologies to acquire these results -- in the form of execution times -- must first be presented.
Additionally, for reproducibility and assurances of realistic scientific applications, the codes, settings and range of heterogeneous accelerator devices must be disclosed.-->
Results and analysis are reported for twelve benchmark codes on a diverse set of architectures -- three Intel CPUs, five Nvidia GPUs, six AMD GPUs and a Xeon Phi.
This chapter is based on our publication in the Proceedings of the 47^th^ International Conference on Parallel Processing Companion, ICPP 2018 [@johnston18opendwarfs].

## Extending the OpenDwarfs Benchmark Suite

\label{sec:extending_the_opendwarfs_benchmark_suite}

The OpenDwarfs benchmark suite comprises a variety of OpenCL codes, classified according to the Dwarf Taxonomy [@asanovic2006landscape].
The original suite focused on collecting representative benchmarks for scientific applications, with a thorough diversity analysis to justify the addition of each benchmark to the corresponding suite.
We extend these efforts to achieve a full representation of each dwarf, both by integrating other benchmark suites and adding custom kernels.
It lacked coverage across all dwarfs, specifically, no representative application of the Map Reduce dwarf was identified, and the Spectral Methods Dwarf had an FFT application that either generated incorrect results or crashed.

The K-Means clustering benchmark was originally classified as the Dense Linear Algebra Dwarf, however, we believe the K-means clustering algorithm is better represented by the Map Reduce Dwarf.
Dense Linear Algebra applications generally use unit-stride memory accesses to read data from rows and strided accesses to read data from columns, while Map Reduce calculations are considered embarrassingly parallel where a single function executes on independent data sets with outputs that are eventually combined to form a single or small number of results.
K-means is an iterative algorithm which groups a set of points into clusters, such that each point is closer to the centroid of its assigned cluster than to the centroid of any other cluster.
Each step of the algorithm assigns each point to the cluster with the closest centroid, then relocates each cluster centroid to the mean of all points within the cluster.
Execution terminates when no clusters change membership between iterations.
Starting positions for the centroids are determined randomly.
As such, we reclassified K-Means to the Map Reduce dwarf in EOD.
The algorithm and its implementation are further discussed in [Section @sec:kmeans].

For the Spectral Methods dwarf, the original OpenDwarfs version of the FFT benchmark was complex, with several code paths that were not executed for the default problem size, and returned incorrect results or failures on some combinations of platforms and problem sizes we tested.
We replaced it with a simpler high-performance FFT benchmark created by Eric Bainville [@bainville2010fft], which worked correctly in all our tests.
We have also added a 2-D discrete wavelet transform from the Rodinia suite [@che2009rodinia] -- with modifications to improve portability.
The final coverage of all the dwarfs and their benchmarks is presented in Table \ref{table:applications-and-dwarf}.

\begin{table}
\centering
\caption{List of Extended OpenDwarfs Applications and their respective dwarfs.}
\label{table:applications-and-dwarf}
\begin{adjustbox}{max width=0.7\textwidth}
\begin{tabular}{@{}ll@{}}
\hline {Dwarf} & {Extended OpenDwarfs Application}\\\hline

Dense Linear Algebra & LU Decomposition\\
Sparse Linear Algebra & Compressed Sparse Row\\
Spectral Methods & DWT2D, FFT\\
N-Body Methods & Gemnoui\\
Structured Grid & Speckle Reducing Anisotropic Diffusion\\
Unstructured Grid & Computational Fluid Dynamics\\
Map Reduce & K-Means\\
Combinational Logic & Cyclic-Redundancy Check\\
Graph Traversal & Breadth First Search\\
Dynamic Programming & Smith-Waterman\\
Backtrack and Branch and Bound & N-Queens\\
Graphical Methods & Hidden Markov Models\\
Finite State Machines & Temporal Data Mining\\
\hline

\end{tabular}
\end{adjustbox}
\end{table}


Marjanović et al. [@marjanovic2016hpc] argue that the selection of problem size for HPC benchmarking critically affects which hardware properties are relevant.
We have observed this to be true across a wide range of accelerators, therefore we have enhanced the OpenDwarfs benchmark suite to support running different problem sizes for each benchmark.
EOD supports four problem sizes based on the working memory footprint of each benchmark in execution.
These are tiny, small, medium and large, and were selected in accordance to levels in the CPU memory hierarchy -- which is the type of accelerator most affected by size.
In enabling multiple problem sizes, we needed to: i)  generate input sets for multiple problem sizes, ii) fix issues with code that has been developed on GPU but show memory violations on the CPU, and, iii) determine which parameters could be fixed and which need to be adjusted to have a different working memory footprint.

Where possible each benchmark now supports running with arbitrary problem sizes.
The exceptions are Gemnoui, N-Queens, Hidden Markov Models and Smith-Waterman, where we only offer a fixed problem size for these applications.
This is because specifying problem size according to working memory footprint does not work for these benchmarks -- for instance N-Queens has a small working memory footprint and this benchmark is highly compute-bound, increasing the number of queens placed on a board is computationally intense at 20 queens, increasing the problem size to several thousand queens to satisfy the memory conditions for small sized benchmarks would take several orders of magnitude longer than the other benchmarks to solve.

We also added python scripts with these fixed parameters to allow the rapid collection of performance results on new accelerators.
To improve reproducibility of results, we also modified each benchmark to execute in a loop for a minimum of two seconds, to ensure that sampling of execution time and performance counters was not significantly affected by operating system noise.

Our philosophy for the benchmark suite is that firstly, it *must* run on all devices, and secondly, it *should* run well on them.
To this end, we removed hardware specific optimizations from codes that would either diminish performance or crash the application entirely when executed on other devices.

To understand benchmark performance, it is useful to be able to collect hardware performance counters associated with each timing segment.
LibSciBench is a performance measurement tool which allows high precision timing events to be collected for statistical analysis [@hoefler2015scientific].
It offers a high-resolution timer in order to measure short running kernel codes, reported with one cycle resolution and roughly \SI{6}{\nano\second} of overhead.
We used LibSciBench to record timings in conjunction with hardware events, which it collects via PAPI [@mucci1999papi] counters.
We modified the applications in the OpenDwarfs benchmark suite to insert library calls to LibSciBench to record timings and PAPI events for the three main components of application time: kernel execution, host setup and memory transfer operations.
Through PAPI modules such as Intel's Running Average Power Limit (RAPL)[@david2010rapl] and Nvidia Management Library (NVML) [@kasichayanula2012power], LibSciBench also supports energy measurements, for which we report preliminary results in this chapter.


## Experimental Setup

### Hardware

\label{ssec:hardware}
\begin{table*}[t]
\centering
\caption{Hardware utilized during the Extended OpenDwarfs Benchmark Suite evaluation.}\label{tbl:hardware}
\begin{threeparttable}
    \centering
    \resizebox{\linewidth}{!}{%
    \begin{tabular}{l|c|c|c|r|c|c|r|c}
        Name         & Vendor   & Type  & Series    & \multicolumn{1}{m{1cm}|}{\centering Core Count} & \multicolumn{1}{m{2.5cm}|}{\centering Clock Frequency (\si{\mega\hertz}) (min/max/turbo)}  &\multicolumn{1}{m{2.1cm}|}{\centering Cache (\SI{}{\kibi\byte}) (L1/L2/L3)} & \multicolumn{1}{m{.8cm}|}{\centering TDP (\SI{}{\watt})} &  \multicolumn{1}{m{1cm}}{\centering Launch  Date} \\ \hline
        Xeon E5-2697 v2  & Intel    & CPU   &Ivy Bridge & 24$\ast$ &1200/2700/3500 & 32/256/30720 & 130 & Q3 2013\\
        i7-6700K & Intel    & CPU   &Skylake & 8$\ast$ & 800/4000/4300 & 32/256/8192& 91 & Q3 2015\\
        i5-3550  & Intel    & CPU   & Ivy Bridge & 4$\ast$ & 1600/3380/3700 & 32/256/6144& 77 & Q2 2012\\
        Titan X & Nvidia & GPU & Pascal & 3584\textdagger & 1417/1531/-- & 48/2048/-- & 250 & Q3 2016\\
        GTX 1080 & Nvidia & GPU & Pascal & 2560\textdagger & 1607/1733/-- & 48/2048/-- & 180 & Q2 2016\\
        GTX 1080 Ti & Nvidia & GPU & Pascal & 3584\textdagger & 1480/1582/-- & 48/2048/-- & 250 & Q1 2017\\
        K20m & Nvidia & GPU & Kepler & 2496\textdagger & 706/--/-- & 64/1536/-- & 225 & Q4 2012\\
        K40m & Nvidia & GPU & Kepler & 2880\textdagger & 745/875/-- & 64/1536/-- & 235 & Q4 2013\\
        FirePro S9150 & AMD & GPU & Hawaii & 2816$\|$ & 900/--/-- & 16/1024/-- & 235 & Q3 2014\\
        HD 7970       & AMD & GPU & Tahiti & 2048$\|$ & 925/1010/-- & 16/768/-- & 250 & Q4 2011\\
        R9 290X       & AMD & GPU & Hawaii & 2816$\|$ & 1000/--/-- & 16/1024/--& 250 & Q3 2014\\
        R9 295x2      & AMD & GPU & Hawaii & 5632$\|$ & 1018/--/-- & 16/1024/--& 500 & Q2 2014\\
        R9 Fury X     & AMD & GPU & Fuji   & 4096$\|$ & 1050/--/-- & 16/2048/--& 273 & Q2 2015\\
        RX 480        & AMD & GPU & Polaris& 4096$\|$ & 1120/1266/-- & 16/2048/-- & 150 & Q2 2016\\
        Xeon Phi 7210 & Intel & MIC & KNL & 256\textdaggerdbl & 1300/1500/-- & 32/1024/-- & 215 & Q2 2016\\
    \end{tabular}}
    \begin{tablenotes}
    \item [$\ast$] HyperThreaded cores
    \item [\textdagger] CUDA cores
    \item [$\|$] Stream processors
    \item [\textdaggerdbl] Each physical core has 4 hardware threads per core, thus 64 cores
    \end{tablenotes}
\end{threeparttable}
\end{table*}

The experiments were conducted on a varied set of 15 hardware platforms: three Intel CPU architectures, five Nvidia GPUs, six AMD GPUs, and one MIC (Intel Knights Landing Xeon Phi).
The selection of hardware was largely determined by the availability of these systems.
CPU, Consumer GPU, HPC/Scientific GPUs -- the K20m, K40m and FirePro GPUs --  and MIC type accelerators are included and span 6 years of microarchitecture changes.
Key characteristics of the test platforms are presented in Table \ref{tbl:hardware}.
The L1 cache size should be read as having both an instruction cache and a data cache of the size displayed. 
For Nvidia GPUs, the L2 cache size reported is the size of the L2 cache per SM multiplied by the number of SMs.
For the Intel CPUs, hyper-threading was enabled and the frequency governor was set to `performance`.

### Software{#sec:software}

OpenCL version 1.2 was used for all experiments.
On the CPUs, we used the Intel OpenCL driver version 6.3, provided in the 2016-R3 opencl-sdk release.
On the Nvidia GPUs we used the Nvidia OpenCL driver version 375.66, provided as part of CUDA 8.0.61, AMD GPUs used the OpenCL driver version provided in the amdappsdk v3.0.

The Knights Landing (KNL) architecture used the same OpenCL driver as the Intel CPU platforms, however, the 2018-R1 release of the Intel compiler was required to compile for the architecture natively on the host.
Additionally, due to Intel removing support for OpenCL on the KNL architecture, some additional compiler flags were required.
Unfortunately, as Intel has removed support for AVX2 vectorization (using the `-xMIC-AVX512` flag), vector instructions use only 256-bit registers instead of the wider 512-bit registers available on KNL.
This means that floating-point performance on KNL is limited to half the theoretical peak.

GCC version 5.4.0 with glibc 2.23 was used for the Skylake i7 and GTX 1080,
GCC version 4.8.5 with glibc 2.23 was used on the remaining platforms.
OS Ubuntu Linux 16.04.4 with kernel version 4.4.0 was used for the Skylake CPU and GTX 1080 GPU, Red Hat 4.8.5-11 with kernel version 3.10.0 was used on the other platforms.

As OpenDwarfs has no stable release version, it was extended from the last commit by the maintainer on 26 Feb 2016. [@opendwarfs2017base]
LibSciBench version 0.2.2 was used for all performance measurements.


### Measurements


We measured execution time and energy for individual OpenCL kernels within each benchmark.
Each benchmark run executed the application in a loop until at least two seconds had elapsed, and the mean execution time for each kernel was recorded.
Each benchmark was run 50 times for each problem size (see \S\ref{sec:setting_sizes}) for both execution time and energy measurements.
A sample size of 50 was used to ensure that sufficient statistical power $\beta = 0.8$ would be available to detect a significant difference in means on the scale of half standard deviation of separation.
This sample size was computed using the t-test power calculation over a normal distribution.
<!--
To help understand the timings, the following hardware counters can also be collected:
\begin{itemize}
	\item total instructions and IPC (Instructions Per Cycle);
	\item L1 and L2 data cache misses;
	\item total L3 cache events in the form of request rate (requests / instructions), miss rate (misses / instructions), and miss ratio (misses/requests);
	\item data TLB (Translation Look-aside Buffer) miss rate (misses / instructions); and
	\item branch instructions and branch mispredictions.
\end{itemize}
-->
For each benchmark we also measured memory transfer times between host and device, however, only the kernel execution times and energies are presented here.
Energy measurements were taken on Intel platforms using the RAPL PAPI module, and on Nvidia GPUs using the NVML PAPI module.

### Problem Size {#sec:setting_sizes}

This section outlines the choice of problem size, defines the “tiny”, “small”, “medium” and “large” sizes and describes how they are influenced by cache size.
A discussion around each benchmark, how it operates and how it was extended is presented.
This section concludes with the arguments to reproduce our selected problem sizes for the EOD benchmarks.

For each benchmark, four different problem sizes were selected, namely **tiny**, **small**, **medium** and **large**.
These problem sizes are based on the memory hierarchy of the Skylake CPU.
Specifically, **tiny** should just fit within L1 cache, on the Skylake this corresponds to \SI{32}{\kibi\byte} of data cache, **small** should fit within the \SI{256}{\kibi\byte} L2 data cache, **medium** should fit within \SI{8192}{\kibi\byte} of the L3 cache, and **large** must be much larger than \SI{8192}{\kibi\byte} to avoid caching and operate out of main memory.

The memory footprint was verified for each benchmark by printing the sum of the size of all memory allocated on the device.
The applications examined in this work are presented in Table \ref{table:applications-and-dwarf} alongside their representative dwarf from the Berkeley Taxonomy.

For this study, problem sizes were not customized to the memory hierarchy of each platform, since the CPU is the most sensitive to cache performance.
Also, note for these CPU systems the L1 and L2 cache sizes are identical, and since we ensure that **large** is at least $4\times$ larger than L3 cache, we are guaranteed to have last-level cache misses for the **large** problem size.

<!--
The caching performance was measured using PAPI counters, but for brevity is not presented.
On the Skylake L1 and L2 data cache miss rates were counted using the `PAPI_L1_DCM` and `PAPI_L2_DCM` counters.
For L3 miss events, only the total cache counter event (`PAPI_L3_TCM`) was available.
The final values presented as miss results are presented as a percentage, and were determined using the number of misses counted divided by the total instructions (`PAPI_TOT_INS`).
-->

The methodology to determine the appropriate size parameters is demonstrated in the k-means benchmark.

### kmeans{#sec:kmeans}
K-means is an iterative algorithm which groups a set of points into clusters, such that each point is closer to the centroid of its assigned cluster than to the centroid of any other cluster.
Each step of the algorithm assigns each point to the cluster with the closest centroid, then relocates each cluster centroid to the mean of all points within the cluster.
Execution terminates when no points move between clusters between iterations.
Starting positions for the centroids are determined randomly.
The OpenDwarfs benchmark previously required the object features to be read from a previously generated file.
We extended the benchmark to support the generation of a random distribution of points.
This was done to more fairly evaluate cache performance since repeated runs of clustering on the same feature space (loaded from file) would deterministically generate similar caching behaviour.
For all problem sizes, the number of clusters is fixed at 5.

Given a fixed number of clusters, the parameters that may be used to select a problem size are the number of points $P_n$, and the dimensionality or number of features per point $F_n$.
In the kernel for k-means, there are three large one-dimensional arrays passed to the device, namely **feature**, **cluster** and **membership**.
In the **feature** array which stores the unclustered feature space, each feature is represented by a 32-bit floating-point number, so the entire array is of size $P_n \times F_n \times \text{sizeof}\left(\text{float}\right)$.
**cluster** is the working and output array to store the intermediately clustered points, it is of size $C_n \times F_n \times \text{sizeof}\left(\text{float}\right)$, where $C_n$ is the number of clusters.
**membership** is an array indicating whether each point has changed to a new cluster in each iteration of the algorithm, it is of size $P_n \times \text{sizeof}\left(\text{int}\right)$, where $\text{sizeof}\left(\text{int}\right)$ is the number of bytes to represent an integer value.
Thereby the working kernel memory, in \si{\kibi\byte}, is:
\begin{equation}
    \frac{\text{size}\left(\textbf{feature}\right)+\text{size}\left(\textbf{membership}\right)+\text{size}\left(\textbf{cluster}\right)}{1024}
    \label{eq:kmeans_size}
\end{equation}

Using this equation, we can determine the largest problem size that will fit in each level of cache.
The tiny problem size is defined to have 256 points and 30 features; from Equation \ref{eq:kmeans_size}, the total size of the main arrays is \SI{31.5}{\kibi\byte}, slightly smaller than the \SI{32}{\kibi\byte} L1 cache.
The number of points is increased for each larger problem size to ensure that the main arrays fit within the lower levels of the cache hierarchy, measuring the total execution time and respective caching events.
The **tiny**, **small** and **medium** problem sizes in the first row of Table \ref{tab:problem_sizes} correspond to L1, L2 and L3 cache respectively.
The **large** problem size is at least four times the size of the last-level cache -- in the case of the Skylake, at least \SI{32}{\mebi\byte} -- to ensure that data are transferred between main memory and cache.

For brevity, cache miss results are not presented in this chapter but were used to verify the selection of suitable problem sizes for each benchmark.
The procedure to select problem size parameters is specific to each benchmark but follows a similar approach to k-means.

### lud, fft, srad, crc, nw
The LU-Decomposition `lud`, Fast Fourier Transform `fft`, Speckle Reducing Anisotropic Diffusion `srad`, Cyclic Redundancy Check `crc` and Needleman-Wunsch `nw` benchmarks did not require additional data sets.
Where necessary these benchmarks were modified to generate the correct solution and run on modern architectures.
Correctness was examined either by directly comparing outputs against a serial implementation of the codes (where one was available) or by adding utilities to compare norms between the experimental outputs.

### csr
The Compressed Sparse Row format is used to store sparse matrices by storing only non-zero values and their positions.
It allows for large space savings compared to a dense matrix format, but the algorithm adds computationally intensive lookup steps to process the data.
Three different arrays are used to track the locations and values in a matrix.
The benchmark implementation performs a number of matrix operations such as computing the Laplacian and performing a binary search over the irregularly spaced data.
It has been extended by using the `createcsr` application to create 99.5% sparse matrices of our four selected problem sizes.

### dwt
Two-Dimensional Discrete Wavelet Transform is commonly used in image compression.
It has been extended to support loading of Portable PixMap (.ppm) and Portable GrayMap (.pgm) image format and storing Portable GrayMap images of the resulting DWT coefficients in a visual tiled fashion.
The input image dataset for various problem sizes was generated by using the resize capabilities of the ImageMagick application.
The original gum leaf image is the large sample size with a ratio of $3648 \times 2736$ pixels and was down-sampled to $1152 \times 864$ for medium, $200 \times 150$ for small and $72 \times 54$ for the tiny problem size.

### gem, nqueens, hmm, swat
For four of the benchmarks, we were unable to generate different problem sizes to properly exercise the memory hierarchy.

Gemnoui \texttt{gem} is an n-body-method based benchmark which computes electrostatic potential of biomolecular structures.
Determining suitable problem sizes was performed by initially browsing the National Center for Biotechnology Information's Molecular Modeling Database (MMDB)[@madej2013mmdb] and inspecting the corresponding Protein Data Bank format (pdb) files.
Molecules were then selected based on complexity since the greater the complexity the greater the number of atoms required for the benchmark and thus the larger the memory footprint.
**tiny** used the Prion Peptide 4TUT[@yu2015crystal] and was the simplest structure, consisting of a single protein (1 molecule), it had the device side memory usage of \SI{31.3}{\kibi\byte} which should fit in the L1 cache (\SI{32}{\kibi\byte}) on the Skylake processor.
**small** used a Leukocyte Receptor 2D3V[@shiroishi2006crystal] also consisting of 1 protein molecule, with an associated memory footprint of 252KiB.
**medium** used the nucleosome dataset originally provided in the OpenDwarfs benchmark suite, using \SI{7498}{\kibi\byte} of device-side memory.
**large** used an X-Ray Structure of a Nucleosome Core Particle[@davey2002solvent], consisting of 8 protein, 2 nucleotide, and 18 chemical molecules, and requiring \SI{10970.2}{\kibi\byte} of memory when executed by \texttt{gem}.
Each \texttt{pdb} file was converted to the \texttt{pqr} atomic particle charge and radius format using the \texttt{pdb2pqr}[@dolinsky2004pdb2pqr] tool.
Generation of the solvent excluded molecular surface used the tool \texttt{msms} [@sanner1996reduced].
Unfortunately, the molecules used for the **medium** and **large** problem sizes contain uninitialized values only noticed on CPU architectures and as such further work is required to ensure correctness for these larger problem sizes.
Although the **small** sized results have been collected, to be consistent with the other fixed sized benchmarks only the **tiny** problem size is presented.
The datasets used for \texttt{gem} and all other benchmarks can be found in this chapter's associated GitHub repository [@johnston2017].

The \texttt{nqueens} benchmark is a good representative of backtrack/branch-and-bound code which finds valid placements of queens on a chessboard of size n$\times$n, where each queen cannot be attacked by another.
For this code, memory footprint scales very slowly with the increasing number of queens, relative to the computational cost.
Thus it is significantly compute-bound and only one problem size is tested.

The Baum-Welch Algorithm Hidden Markov Model \texttt{hmm} benchmark represents the Graphical Models dwarf and did not require additional data sets, however, uninitialized values are encountered when considering problem sizes larger than **tiny**.
The **tiny** problem size has been validated -- results are correct -- and, as such, it is the only size presented in the evaluation.

Smith-Waterman alignment `swat` is a variation of the Needleman-Wunsch algorithm, used for computing local sequence alignment. 
The original OpenDwarfs suite included a selection of data files, but no method to generate arbitrarily-sized inputs, as such, only the tiny problem size is considered.


###bfs, cfd, tdm

<!--
The `bfs` benchmark was extended, such that, the dataset generator was shipped with the OpenDwarfs benchmark suite graphs and was used to generate the four problem sizes.
These sizes were verified by profiling working memory of the bfs application during execution.
However, the results are not presented in this thesis because various problem sizes resulted in uninitialized memory access -- indicating an error in the benchmark -- and verification of the legitimacy of the results was not performed.
Identifying the error and understanding the cause of this error is interesting but is not the goal of this thesis.

The `cfd` and `tdm` are part of the original OpenDwarfs benchmark suite however due to time constraints these benchmarks were not extended.
The primary reason for the lack of extensions on these benchmarks is their reliance on separate datasets which need to be specifically regenerated based on problem sizes.
The generation of which use either a) missing, or b) broken legacy codes, to generate data for non-standard formats.
For instance, `cfd` solves three-dimensional Euler equations over a finite volume for compressible flow.
However, the objects within the volume are represented as a triangular mesh of vertices one sample aircraft wing mesh is provided alongside the OpenDwarfs benchmark suite but no method to produce the dataset is given.
We attempted down and upsampling the resolution of this mesh to yield appropriate size datasets for our purposes of problem sizes, however, this was unsuccessful and resulted in many uninitialized memory accesses and crashes.
Furthermore, the `tdm` benchmark uses two files, one a containing temporal database, and another file containing the temporal constraints but the codes to generate these files were unavailable.
All these benchmarks require a large degree of software engineering to reverse engineer the data structures and ensure correctness.
They are included in Table \ref{table:applications-and-dwarf} as they provide coverage over their respective dwarfs but no listings around extensions or performance results are included in this thesis.
-->
Results for `bfs` are not presented due to an error in the OpenDwarfs benchmark code.
Results for `cfd` and `tdm` are not presented as the provided datasets were invalid and no dataset generator was available.

### Summary of Benchmark Settings

The problem size parameters for all benchmarks are presented in Table \ref{tab:problem_sizes}.

\begin{table}[thb]
	\centering
	\begin{threeparttable}
		\centering
    \caption{The different problem sizes in the Extended OpenDwarfs adjusted by selecting the workload scale parameter ($\Phi$).}
		\begin{tabular}{l|c|c|c|c}
            \bf Benchmark         & \bf tiny   & \bf small  & \bf medium     & \bf large\\\hline
            \texttt{kmeans} & 256 & 2048 & 65600 & 131072\\
            \texttt{lud}             & 80         & 240    & 1440       & 4096\\
            \texttt{csr}             & 736        & 2416   & 14336      & 16384\\
            \texttt{fft}             & 2048       & 16384  & 524288     & 2097152\\
            \texttt{dwt}             & 72x54      & 200x150 & 1152x864   & 3648x2736\\       
            \texttt{srad}            & 80,16      & 128,80 & 1024,336   & 2048,1024\\
            \texttt{crc}             & 2000       & 16000  & 524000     & 4194304\\
            \texttt{nw}              & 48         & 176    & 1008       & 4096\\
            \texttt{gem}             & 4TUT       & --  & -- & --\\
            \texttt{nqueens}         & 18         & -- & -- & --\\
            \texttt{hmm}             & 8,1        & --  & --  & --\\
            %\texttt{gem}             & 4TUT       & 2D3V   & nucleosome & 1KX5\\
            %\texttt{nqueens}         & 18         & -- & -- & --\\
            %\texttt{hmm}             & 8,1        & 900,1  & 1012,1024  & 2048,2048\\
            %\texttt{cfd}             & 128        & 1284   & 45056      & 193474
            %\texttt{bfs}             & 650        & 5376   & 172032     & 1048576\\
            \texttt{swat}            & 1k1       & -- & -- & --\\
            %\texttt{tdm}             & --         & -- & -- & --\\
		\end{tabular}
		\label{tab:problem_sizes}
	\end{threeparttable}
\end{table}

Each **Device** can be selected in a uniform way between applications using the same notation, on our sample system **Device** comprises of \texttt{-p 1 -d 0 -t 0} for the Intel Skylake CPU, where \texttt{p} and \texttt{d} are the integer identifier of the platform and device to respectively use, and \texttt{-p 1 -d 0 -t 1} for the Nvidia GeForce GTX 1080 GPU.
The availability and ordering of platform and device ids vary between nodes and will need to be adjusted accordingly.
Each application is run as **Benchmark** **Device** \texttt{--} **Arguments**, where **Arguments** is taken from Table \ref{tab:program_arguments} at the selected scale of $\Phi$.
For reproducibility, the entire set of Python scripts with all problem sizes is available in a GitHub repository [@johnston2017]. 
Where $\Phi$ is substituted as the argument for each benchmark, it is taken as the respective scale from Table \ref{tab:problem_sizes} and is inserted into Table \ref{tab:program_arguments}.

\begin{table}[t]
	\centering
	\begin{threeparttable}
		\centering
		\captionof{table}{Program Arguments for benchmarks in the Extended OpenDwarf Suite.}
		\vspace{0pt}
		\begin{tabular}{l|l}
			\bf Benchmark & \bf Arguments\\\hline
			{\tt kmeans} & {\tt -g -f 26 -p} $\Phi$\\
			{\tt lud} & {\tt -s} $\Phi$\\
			{\tt csr}\textdagger & {\tt -i} $\Psi$\\
			      & $\Psi$ = {\tt createcsr -n} $\Phi$ {\tt -d 5000} $\medtriangleup$\\
			{\tt fft} & $\Phi$ \\
			{\tt dwt} & {\tt -l 3 }$\Phi${\tt-gum.ppm}\\
			{\tt srad}& $\Phi_1$ $\Phi_2$ {\tt 0 127 0 127 0.5 1}\\
			{\tt crc}&  {\tt -i 1000\_}$\Phi${\tt.txt}\\
			%{\tt cfd} & $\Phi${\tt.dat}\\
            %{\tt bfs}&  {\tt 'graph}$\Phi${\tt.txt'}\\
            {\tt nw}&  $\Phi${ 10}\\
            {\tt gem} & $\Phi$ {80 1 0}\\
            {\tt n-queens} & $\Phi$\\
            {\tt hmm}&  {\tt -n }$\Phi_1${\tt -s }$\Phi_2${\tt -v s}\\
            {\tt swat}& {\tt 'query}$\Phi${\tt'} {\tt 'sampledb}$\Phi${\tt'}\\
		\end{tabular}
		\begin{tablenotes}
			\item [$\medtriangleup$] The {\tt -d 5000} indicates density of the matrix in this instance 0.5\% dense (or 99.5\% sparse).
			\item [\textdagger] The {\tt csr} benchmark loads a file generated by {\tt createcsr} according to the workload size parameter $\Phi$; this file is represented by $\Psi$.
		\end{tablenotes}
		\label{tab:program_arguments}
	\end{threeparttable}
\end{table}

## Results

The primary purpose of including these time results is to demonstrate the benefits of the extensions made to the OpenDwarfs Benchmark suite.
We use the benchmarks to assess and compare performance across the chosen hardware systems.
The use of LibSciBench allowed high-resolution timing measurements over multiple code regions.
To demonstrate the portability of the Extended OpenDwarfs benchmark suite, we present results from 12 varied benchmarks running on 15 different devices representing four distinct classes of accelerator.
For eight of the benchmarks, we measured multiple problem sizes and observed distinctly different scaling patterns between devices.
This underscores the importance of allowing a choice of problem size in a benchmarking suite.
The primary analysis is for time, but energy results over two devices are also presented.

### Time {#sec:chapter-3-results-time}

The distribution of execution times required to execute each of the benchmarks for all available hardware is presented in Figures \ref{fig:time-medium} and \ref{fig:time-fixed}.
Eight of the benchmark applications offer four different problem sizes, we only present the medium problem size in Figure \ref{fig:time-medium} to highlight the variation in runtimes between benchmarks, while Figure \ref{fig:time-fixed} presents execution times for the four benchmarks with fixed problem size.
The results are coloured according to accelerator type: purple for CPU devices, blue for consumer GPUs, green for HPC GPUs, and yellow for the KNL MIC.

The results presented in Figure\ \ref{fig:time-medium} show the total kernel execution time in milliseconds for each of the benchmark applications on various accelerator devices.
The reported iteration time is the sum of all compute time spent on that accelerator for all kernels.

In Figure\ \ref{fig:time-medium} (a) (\texttt{kmeans}) shows applications typical of the MapReduce dwarf are best suited to GPU devices, this is unsurprising given it has embarrassingly parallel characteristics that are well suited to this accelerator type.
The performance of the various GPU devices generally follows their date of manufacture.
For instance, the Nvidia gaming devices such as the TitanX, GTX 1080 and GTX 1080 Ti are the newest devices and perform best; similar trends emerge in the AMD cards -- the RX 480 has a higher clock frequency (1120 MHz) relative to the oldest AMD device the HD7970 (925 MHz) and performance ranges between these two extremes accordingly.
Interestingly the HPC GPUs buck this trend with a lower clock frequency (706-900MHz) and older manufacture date than many of the gaming GPUs performing at a similar level to the newer AMD gaming GPUs and only 1-2ms slower per kernel run than the newest Nvidia GPU.
This is attributed to the larger number of threads supported on these devices and is a good match to the high-degree of parallelism in the benchmark.
The i7 is the best performer of all the CPU type accelerators, taking 6ms which is 2-3ms slower than the fastest GPU, this is expected since it has the highest clock frequency.
<!--However, the amount of parallelism expressed at a thread level is less suited to this architecture than the GPUs.-->
As the CPUs have fewer hardware threads they are less able to exploit the available parallelism in the benchmark than the GPUs.
The Xeon Phi 7210 MIC is $\approx10-20\times$ slower than the other accelerators, we believe this is due to the lack of vectorization of the kernel.

Figure\ \ref{fig:time-medium} (b) (\texttt{lud}) from the Dense Linear Algebra dwarf shows similar trends.
It is largely well suited to GPUs however is less suited to the HPC scientific cards and the MIC performs better.
The oldest CPU considered (the i5-3550) performs much worse than the other CPU devices, and is because the medium problem size requires 8100KiB of cache which spills outside of the L3 cache 6133KiB on this processor thus this performance is due to the high penalties of L3 cache misses and accessing main memory.

Figure\ \ref{fig:time-medium} (c) (\texttt{csr}) -- Sparse Linear Algebra -- shows a performance which scales with clock-frequency and the newer CPU and GPU devices with the highest frequency offer the shortest execution times.
The i7 CPU and Titan X, GTX 1080 Ti GPUs  are the most suitable accelerators for these type of codes.
Interestingly, the difference in execution times between the GTX 1080 and the GTX 1080 Ti highlights the memory critical nature of this dwarf.
Irregular memory access in sparse matrices benefits the higher memory bandwidth lower latency interconnect in the Ti, where despite being 127-151MHz slower in base clock speed, the doubling in peak memory bandwidth and the extra 125MHz memory clock speeds give the Ti better performance.
The Titan X has a similarly high memory configuration and justifies why it performs as well as the GTX 1080 Ti.

Figure\ \ref{fig:time-medium} (d) (\texttt{fft}) and Figure\ \ref{fig:time-medium} (e) (\texttt{dwt}) represent Spectral Methods.
These benchmarks are high floating point intensity applications which explain the poor suitability of the Xeon Phi 7210 MIC -- which is limited to half the theoretical peak of its floating-point performance as explained in [Section @sec:software].
The CPU devices also suffer from this high floating point demand which has lower raw FLOPs than the GPUs.
On average, the worst performing device over both Spectral Methods applications is the i5-3550 which has the poorest FLOPs of any of the CPUs coupled with the smallest L3 cache which frequently spills over into main memory during execution of these benchmarks.
It is interesting to note that both benchmarks representing the same dwarf have very similar performance results over all the accelerators -- where generally the ordering of optimal device is largely the same between both applications.

Figure\ \ref{fig:time-medium} (f) (\texttt{srad}) represents the Structured Grid dwarf and has similar performance results to `fft` and `dwt`.
This tells us the regular grid points which are updated together are well suited to GPUs and accelerators with higher floating intensity.
The high spatial locality and embarrassingly parallel nature of Structured Grids indicate that it has similar properties to Spectral Methods.

Additional experiments could be performed using the LibSciBench hardware performance counters to confirm our explanation of these poor CPU and MIC results, while Nvidia's Perftool could examine similar hardware metrics on the Nvidia accelerators.
However, since the broader focus of this thesis is to use the evaluation of a range of accelerators over a broad suite of benchmarks, the interest in predicting poor performance is more interesting than a closer level inspection of the deficiencies of each platform.

Figure\ \ref{fig:time-medium} (g) (\texttt{crc}) is from the Combinational Logic dwarf where the benchmark performs error-detecting code caused by network transmission or any other accidental error, work is performed in workgroups determined by polynomial division.
There are no floating point operations within each workgroup and a checksum is computed for each.
Integer vectorization is high and each work-item processes 8 bytes at once using the "Slice-by-8" algorithm.
This requires a large number of bit shifts and conditional loop nesting which results in irregular integer comparisons that are ill-suited to GPU architectures -- which are not optimized for integer operations and suffer from thread-divergence.
GPU devices suffer further since they are not equipped with wide integer units -- 64-bit wide ALUs are typical.
By comparison, CPUs and the MIC are accelerator types which excel at this computation; the high degree of vector parallelism inherent in the algorithm suit the E5-2697 and i7-6700K CPUs with 128-bit and 256-bit wide SIMD units respectively, and is ideal for the MIC which has very wide 512-bit SIMD units.
Examining the `crc` benchmark is examined in greater detail in Figure \ref{fig:time-crc} as problem size increases.

Figures\ \ref{fig:time-medium} (h) (\texttt{nw}) and \ref{fig:time-fixed} (d) (\texttt{swat}) both represent Dynamic Programming.
The order of performance results is also similar, with the newest Nvidia GPUs performing best, the different generations of CPUs falling around the older GPUs and the MIC being the worst performed by a large margin (30%).
The ordering of performance of devices between both benchmarks is similar.
It is equally interesting to note that \ref{fig:time-fixed} (a) (\texttt{gem}) and \ref{fig:time-fixed} (a) (\texttt{nqueens}) also have a similar ordering of fastest accelerator devices.

Comparing the medium problem size between all the benchmarks, we see individual devices with significantly longer execution times than the others, these large differences in execution times hide many of the finer differences in detail between accelerators with similar good performance and identify the penalties when selecting a suboptimal accelerator device.
The Xeon Phi 7210 MIC is 2.5$\times$ slower than the next worse accelerator in the \texttt{kmeans} benchmark, the rest of the accelerators all have average execution times less than 18ms.
It was had the worst execution times for \texttt{csr} and \texttt{nw} benchmarks being 2-4$\times$ slower than the other accelerators.
The i5-3550 performed 6$\times$ worse than the MIC on the \texttt{lud} benchmark which on average take $\approx1$ms.
Similarly, the i5-3550 CPU was the poorest choice of accelerator for \texttt{dwt} and \texttt{srad} benchmarks, being on average 6$\times$ and 5$\times$ slower, respectively, than the other accelerators.
The Xeon Phi and i5-3550 were equally poor on the \texttt{fft} benchmark, taking 12ms per run, despite the other non-CPU accelerators taking less than 2ms.
Finally, the GPUs performed worse on the \texttt{crc} benchmark, with the K20m taking 100ms, compared to the CPU and MIC taking <5ms.
These large differences in execution times show the importance in selecting an optimal accelerator by highlighting the large difference between the good performance of accelerators on average and the poorest device for a benchmark -- it results in a 2-100$\times$ longer execution time.

Figure \ref{fig:time-fixed} presents results for the four applications with restricted problem sizes.
The per kernel invocation is relatively low regardless of device selected for the (a) \texttt{gem} or (b) \texttt{nqueens} benchmark.
The newer Nvidia GPUs collectively tended to be the best-performed accelerator on \texttt{gem} taking $\approx110\mu$s while the MIC saw the worst performance at 0.85 ms.
The \texttt{nqueens} benchmark saw the i7-6700K and i5-3550 CPUs finish the kernel in $\approx80\mu$s to $\approx100\mu$s per invocation, respectively, again the MIC had the worst performance at $900\mu$s on average.
Figures (c) \texttt{hmm} and (d) \texttt{swat} are more computationally intensive and took longer to complete.
The \texttt{hmm} benchmark shows the CPU and modern Nvidia GPUs performing equally well < 1ms, the older AMD and HPC GPUs ranged from 1-3ms, and the MIC averaged 7.5ms per run.
Finally, \texttt{swat} had the modern Nvidia GPUs as the fastest devices at $\approx5$ms and ranged up to 40ms on the MIC which was the slowest device for this benchmark.

We selected the \texttt{crc} and \texttt{kmeans} benchmarks for the detailed analysis to show how the amount of work increases over each of the four problem sizes, since the former experiences exceptionally good performance on the KNL MIC, while the latter typifies the benchmarks suitable to GPU architectures as problem size increases.

The \texttt{crc} benchmark is a standout in benchmarks for the MIC; it the only benchmark where the MIC is competitive with the other accelerators, probably due to the low floating-point intensity of the crc computation[@joshi2016thesis].
The effect of problem size on this application is presented as Figure \ref{fig:time-crc}.
Starting with the tiny size, it experiences comparable performance to all of the older GPUs, for the small size it offers similar performance to the latest Nvidia GPUs, and for the medium and large problem sizes its performance rivals the CPU accelerators.
This is due to the larger problem sizes generating enough work to fully utilize the 512-bit wide SIMD units over the 256-threads on the MIC.

We have omitted the KNL MIC platform from the \texttt{kmeans} results in Figure \ref{fig:time-kmeans} because they are typically an order of magnitude worse than the other devices.
The full results with the MIC device are presented in Appendix \ref{appendix:time-results}.
The devices are grouped in this analysis: CPU devices (1-3) are presented in purple; the high-performance GPUs designed for scientific workloads (devices 7-9) are presented in green; the modern Nvidia GPUs are in blue to the left of  HPC GPUs (devices 4-6); and the last group consists of the older AMD GPUs (devices 10-14) and are also in  blue to the right of the green results.
Both groups of Nvidia GPUs and AMD GPUs are both presenting in blue since they are both consumer GPUs.
As problem size increases, the order of devices in a group rarely changes and only the magnitude of differences increase between groups.
The CPU accelerator group performs worse as the problem size increases, this is because performance is tightly bound to the level of the cache hierarchy used.
The modern Nvidia GPU was the 2nd fastest set of devices in the tiny problem size, and this performance improved under the demand of larger workloads and culminates in being 2-5$\times$ faster than the CPU devices.
HPC GPUs had average performance over the increasing problem sizes, while the HD7970 GPU suffered worse runtimes relative to the rest of the AMD gaming GPUs, this confirms that the performance of this benchmark corresponds to clock frequency and FLOPs achievable for the devices.

The entire set of results and a detailed discussion is presented in Appendix \ref{appendix:time-results}.

\begin{figure}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/medium_apps}
    \caption{Kernel execution times for the medium problem size benchmarks on different accelerator devices.}
    \label{fig:time-medium}
\end{figure}

\begin{figure}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/gem_nqueens_hmm_and_swat}
    \caption{Kernel execution times for the single sized benchmarks on various accelerator devices.}
    \label{fig:time-fixed}
\end{figure}

\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/crc}
    \caption{Kernel execution times for the {\bf crc} benchmark on different hardware platforms}
    \label{fig:time-crc}
\end{figure*}

\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/kmeans}
    \caption{Kernel execution times for the {\bf kmeans} benchmark on different hardware platforms}
    \label{fig:time-kmeans}
\end{figure*}


<!--
We first present execution time measurements for each benchmark, starting with the Cyclic Redundancy Check \texttt{crc} benchmark which represents the Combinational Logic dwarf.

\begin{figure*}[t]
	\centering
	\includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/crc}
	\caption{Kernel execution times for the {\bf crc} benchmark on different hardware platforms}
	\label{fig:time-crc}
\end{figure*}

Figure\ \ref{fig:time-crc} shows the execution times for the \texttt{crc} benchmark over 50 iterations on each of the target architectures, including the KNL MIC.

The results are colored according to accelerator type: purple for CPU devices, blue for consumer GPUs, green for HPC GPUs, and yellow for the KNL MIC.
Execution times for \texttt{crc} are lowest on CPU-type architectures, probably due to the low floating-point intensity of the CRC computation\[Ch. 6\][@joshi2016thesis].
Excluding \texttt{crc}, all the other benchmarks perform best on GPU type accelerators; furthermore, the performance on the KNL is poor due to the lack of support for wide vector registers in Intel's OpenCL SDK.
We, therefore, omit results for KNL for the remaining benchmarks.

Figures\ \ref{fig:tiny-and-small-time},\ \ref{fig:medium-and-large-time},\ \ref{fig:tiny-and-small-time2} and\ \ref{fig:medium-and-large-time2} shows the distribution of kernel execution times for the remaining benchmarks.
The **tiny** and **small** sizes for the `kmeans`, `lud`, `csr` and `dwt` benchmarks are presented in Figure\ \ref{fig:tiny-and-small-time} results, the **medium** and **large** problem sizes are presented in Figure\ \ref{fig:medium-and-large-time}.
Similarly, the final three applications which support multiple problem sizes -- \texttt{fft}, \texttt{srad} and \texttt{nw} -- display the time results for **tiny** and **small** in Figure\ \ref{fig:tiny-and-small-time2}, and **medium** and **large** times are shown in Figure\ \ref{fig:medium-and-large-time2}.
Some benchmarks execute more than one kernel on the accelerator device; the reported iteration time is the sum of all compute time spent on the accelerator for all kernels.
Each benchmark corresponds to a particular dwarf: 
From Figures\ \ref{fig:tiny-and-small-time} and \ref{fig:medium-and-large-time} (a) (\texttt{kmeans}) represents the MapReduce dwarf,
(b) (\texttt{lud}) represents the Dense Linear Algebra dwarf,
(c) (\texttt{csr}) represents Sparse Linear Algebra, 
(d)  (\texttt{dwt}) and from Figures\ \ref{fig:tiny-and-small-time2}\ (a) and \ref{fig:medium-and-large-time2}\ (a) (\texttt{fft}) represent Spectral Methods,
(b) (\texttt{srad}) represents the Structured Grid dwarf and (c) (\texttt{nw}) represents Dynamic Programming.

Finally, Figure \ref{fig:time3} presents results for the four applications with restricted problem sizes and only one problem size is shown.
The N-body Methods dwarf is represented by (\texttt{gem}) and the results are shown in Figure \ref{fig:time3}\ (a), the Backtrack \& Branch and Bound dwarf is represented by the (\texttt{nqueens}) application in Figure \ref{fig:time3}\ (b), (\texttt{hmm}) results from Figure \ref{fig:time3}\ (c) represent the Graphical Models dwarf and (\texttt{swat}) from Figure \ref{fig:time3}\ (d) also depicts the Dynamic Programming dwarf.

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/tiny_and_small_times_for_kmeans_lud_csr_dwt}
    \caption{Kernel execution times for the \textbf{tiny} and \textbf{small} problem sizes of the \texttt{kmeans}, \texttt{lud}, \texttt{csr} and \texttt{dwt} benchmarks on different hardware platforms}
    \label{fig:tiny-and-small-time}
\end{figure*}

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/medium_and_large_times_for_kmeans_lud_csr_dwt}
    \caption{Kernel execution times for the \textbf{medium} and \textbf{large} problem sizes of the \texttt{kmeans}, \texttt{lud}, \texttt{csr} and \texttt{dwt} benchmarks on different hardware platforms}
    \label{fig:medium-and-large-time}
\end{figure*}

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/tiny_and_small_times_for_fft_srad_nw}
    \caption{Kernel execution times for the \textbf{tiny} and \textbf{small} problem sizes of the \texttt{fft}, \texttt{srad} and \texttt{nw} benchmarks on different hardware platforms}
    \label{fig:tiny-and-small-time2}
\end{figure*}

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/medium_and_large_times_for_fft_srad_nw}
    \caption{Kernel execution times for the \textbf{medium} and \textbf{large} problem sizes of the \texttt{fft}, \texttt{srad} and \texttt{nw} benchmarks on different hardware platforms}
    \label{fig:medium-and-large-time2}
\end{figure*}

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/gem_nqueens_hmm_and_swat}
    \caption{Single problem sized benchmarks of kernel execution times on different hardware platforms}
    \label{fig:time3}
\end{figure*}

Examining the transition from tiny to large problem sizes in Figures \ref{fig:tiny-and-small-time2}\ (b) and \ref{fig:medium-and-large-time2}\ (b) shows the performance gap between CPU and GPU architectures widening for \texttt{srad} -- indicating codes representative of structured grid dwarfs are well suited to GPUs.

In contrast, \texttt{nw} -- (b) from Figures\ \ref{fig:tiny-and-small-time2} and\ \ref{fig:medium-and-large-time2} -- shows that the Intel CPUs and NVIDIA GPUs perform comparably for all problem sizes, whereas all AMD GPUs exhibit worse performance as size increases. This suggests that performance for this Dynamic Programming problem cannot be explained solely by considering accelerator type and may be tied to micro-architecture or OpenCL runtime support.

For most benchmarks, the variability in execution times is greater for devices with a lower clock frequency, regardless of accelerator type.
While execution time increases with problem size for all benchmarks and platforms, the modern GPUs (Titan X, GTX1080, GTX1080Ti, R9 Fury X and RX 480) performed relatively better for large problem sizes, primarily due to their larger second-level cache size compared to the other platforms.
A notable exception is \texttt{kmeans} for which CPU execution times were comparable to GPU, which reflects the relatively low ratio of floating-point to memory operations in the benchmark.

Generally, the HPC GPUs are older and were designed to alleviate global memory limitations amongst consumer GPUs of the time.
(Global memory size is not listed in Table \ref{tbl:hardware}.)
Despite their larger memory sizes, the clock speed of all HPC GPUs is slower than all evaluated consumer GPUs.
While the HPC GPUs (devices 7-9, in green) outperformed consumer GPUs of the same generation (devices 4-6 and 10-13, in blue) for most benchmarks and problem sizes, they were always beaten by more modern GPUs.
This is no surprise since all selected problem sizes fit within the global memory of all devices.

A comparison between CPUs (devices 1-3, in purple) indicates the importance of examining multiple problem sizes.
Medium-sized problems were designed to fit within the L3 cache of the i7-6700K system, and this conveniently also fits within the L3 cache of the Xeon E5-2697 v2.
However, the older i5-3550 CPU has a smaller L3 cache and exhibits worse performance when moving from small to medium problem sizes, and is shown in (b),(d) and (e) in Figures\ \ref{fig:tiny-and-small-time} and\ \ref{fig:medium-and-large-time}, and in (a) from Figures\ \ref{fig:tiny-and-small-time2} and \ref{fig:medium-and-large-time2}.

Increasing problem size also hinders the performance in certain circumstances for GPU devices.
For example, (b) from Figures\ \ref{fig:tiny-and-small-time2} and \ref{fig:medium-and-large-time2} shows a widening performance gap over each increase in problem size between AMD GPUs and the other devices.

Predicted application properties for the various Berkeley Dwarfs are evident in the measured runtime results.
For example, Asanović et al. [@asanovic2006landscape] state that applications from the Spectral Methods dwarf is memory latency limited.
If we examine \texttt{dwt} and \texttt{fft} -- the applications which represent Spectral Methods -- in Figure \ref{fig:medium-and-large-time}\ (d) and Figure\ \ref{fig:medium-and-large-time2}\ (a) respectively, we see that for medium problem sizes the execution times match the higher memory latency of the L3 cache of CPU devices relative to the GPU counterparts.
The trend only increases with problem size: the large size shows the CPU devices frequently accessing main memory while the GPUs' larger memory ensures a lower memory access latency.
It is expected if had we extended this study to an even larger problem size that would not fit on GPU global memory, much higher performance penalties would be experienced over GPU devices, since the PCI-E interconnect has a higher latency than a memory access to main memory from the CPU systems.
As a further example, Asanović et al. [@asanovic2006landscape] state that the Structured Grid dwarf is memory bandwidth limited.
The Structured Grid dwarf is represented by the \texttt{srad} benchmark shown in Figure\ \ref{fig:medium-and-large-time2} (b).
GPUs exhibit lower execution times than CPUs, which would be expected in a memory bandwidth-limited code as GPU devices offer higher bandwidth than a system interconnect.

-->

### Energy

In addition to execution time, we are interested in differences in energy consumption between devices and applications.
We measured the energy consumption of benchmark kernel execution on the Intel Skylake i7-6700k CPU and the Nvidia GTX1080 GPU, using PAPI modules for RAPL and NVML. 
These were the only devices examined since the collection of PAPI energy measurements (with LibSciBench) requires root access, and these devices were the only accelerators available with this permission.
The distributions were collected by measuring solely the kernel execution over 50 runs.
RAPL CPU energy measurements were collected over all cores in package 0 \texttt{rapl:::PP0\_ENERGY:PACKAGE0}.
NVML GPU energy was collected using the power usage readings \texttt{nvml:::GeForce\_GTX\_1080:power} for the device and presents the total power draw (+/-5 watts) for the entire card -- memory and chip.
Measurements results converted to energy \SI{}{\joule} from their original resolution \SI{}{\nano\joule} and \SI{}{\milli\watt} on the CPU and GPU respectively.

From the time results presented in [Section @sec:chapter-3-results-time] we see the largest difference occurs between CPU and GPU type accelerators at the **large** problem size.
Thus we expect that the **large** problem size will also show the largest difference in energy.

\begin{figure*}[htb]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/energy_combined}
\caption{Execution energy required to perform EOD benchmarks, presented on a linear (a) and logarithmic scale (b) from left to right respectively, on the ({\bf large} problem size) on the Intel i7-6700K and Nvidia GTX1080}
    \label{fig:energy}
    \label{fig:energy-log}
\end{figure*}


Figures \ref{fig:energy}\ (a) and \ (b) show the kernel execution energy for several benchmarks for the **large** size.
All results are presented in joules.
The box plots are coloured according to device: purple for the Intel Skylake i7-6700k CPU and blue for the Nvidia GTX1080 GPU.
The logarithmic transformation has been applied to Figure \ref{fig:energy-log}\ (b) to emphasise the variation at smaller energy scales ($<$ \SI{1}{\joule}), which was necessary due to small execution times for some benchmarks.
In future this will be addressed by balancing the amount of computation required for each benchmark, to standardize the magnitude of results.

All the benchmarks use more energy on the CPU, with the exception of `crc` which as previously mentioned has low floating-point intensity and so is not able to make use of the GPU's greater floating-point capability.
The execution times and corresponding energy usage is tightly coupled for all the benchmarks presented.
While not initially apparent in Figures \ref{fig:energy}\ (a) and \ (b) the variability of energy usage is slightly larger on the CPU, which is consistent with the larger variation in execution time results.

## Discussion

In this chapter, we presented EOD which places a strong focus on the robustness of benchmarks, curation of additional benchmarks with an increased emphasis on correctness of results and choice of problem size.
Other improvements focus on adding additional benchmarks to better represent each Dwarf along with supporting a range of 4 problem sizes for each application to allow for a deeper analysis of the memory subsystem on each of these devices.
Having a common back-end in the form of OpenCL allows a direct comparison of identical code across diverse architectures.
We improved coverage of spectral methods by adding a new Discrete Wavelet Transform benchmark, and replacing the previous inadequate fft benchmark.

Older hardware was used in this evaluation, but having a greater diversity between generations of microarchitecture could be useful when examining the general purpose nature of the predictive model in Chapter 5.
Energy results were not able to be collected on many of these systems since we lacked root access, however, we have proposed a methodology that can easily be applied to collect additional energy results on the next generation of hardware.

The work presented in this chapter presents the ground-work required to evaluate the performance of heterogeneous devices from a shared language -- OpenCL.\footnote{No claim is made regarding the optimality of OpenCL for accelerator programming.}
The introduced benchmarking suite  -- EOD -- and the corresponding execution times on the full range of accelerators are used in the remainder of this thesis.
While performance could be individually analysed for each kernel in EOD, we will instead propose to collect results on an abstract OpenCL device to enable a largely automated approach to compare feature-spaces and their suitability/mapping to accelerators.

Additionally, the recorded EOD runtimes from this chapter are used as a testbed for the predictive model presented in Chapter 5.
It serves as a platform which is essential to measure the performance of scientific workloads on accelerators.
The goal of this thesis is scheduling of scientific workloads to accelerator devices which will be a standard feature of the next-generation of HPC nodes.

In general, the results of this chapter identify a few major points.
Firstly, energy is correlated to execution time for most applications.
Secondly, particular accelerator types do not perform best under all applications encompassing a dwarf.
Finally, each dwarf is ill-suited to at least one type of accelerator -- for instance, GPU type accelerators are unsuited to the combinational-logic dwarf.

These last two points reinforce the assumption that there is a most appropriate accelerator for any particular OpenCL code, this, in turn, raises an interesting research question: "can the automatic characterization of a kernel allow the efficient scheduling of work to the most appropriate accelerator"?
Our proposed workload characterization tool -- AIWC -- is introduced in the next Chapter whilst the above question is addressed in [Chapter @sec:chapter-5-accelerator-predictions].

