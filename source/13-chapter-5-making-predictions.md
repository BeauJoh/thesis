# Making Performance Predictions for Scheduling {#sec:chapter-5-accelerator-predictions}

<!--
The Architecture-Independent Workload Characterization (AIWC) tool -- Chapter 4 -- was previously introduced in order to collect architecture-independent features of OpenCL application workload.
AIWC operates on OpenCL kernels by simulating an OpenCL device and performing instrumentation to collect various features to characterize parallelism, compute complexity, memory and control that are independent of the target execution architecture.
-->

Predicting the performance of a particular OpenCL application on a selected accelerator is challenging due to complex interactions between the computational requirements of the code and the capabilities of the target device.
Certain classes of application are better suited to a certain type of accelerator [@che2008accelerating], and choosing the wrong device results in slower and more energy-intensive computation [@fowers2013performance].
The penalties involved in selecting the wrong accelerator for a given code is shown in the ranges between the best and worst execution times of the Figures \ref{fig:time-medium} and \ref{fig:time-fixed} in Chapter 3.
Thus, accelerator selection is critical to making optimal scheduling decisions to achieve good performance in a heterogeneous supercomputing environment.
The ability to predict which device is optimal without having to first run a new code on all devices first is desirable.
AIWC metrics -- from Chapter 4 -- provide a good representation of the characteristics of codes; we propose that these metrics can be used directly for the prediction of execution times over various accelerators.
In this chapter, we develop a model that employs the AIWC features to make accurate predictions over a range of current accelerators.
The execution times from Chapter 3 are used as response variables and the AIWC metrics are used as input variables to train this model.
This chapter discusses how the model is developed and optimized for our data, an evaluation is presented along with a discussion of its use case on predictions for scheduling.

There are many current projects which attempt task scheduling on heterogeneous multicore architectures, these include StarPU [@augonnet2011starpu], Ompss [@duran2011ompss] and CoreTSAR [@scogland2014coretsar]<!-- and AutoMatch [@helal2017automatch].-->
Many of these schedulers track dependencies within tasks and target either compute, bandwidth or latency by scheduling work to the most appropriate accelerator at the granularity of function call level or the work inside a single parallel region.
The history of the performance of a task is used to determine the optimal device to use in the future.
However, the nature of this approach means these schedulers must execute a new kernel code on all available accelerators before any scheduler smart strategies can be used.
Our model can predict the expected execution time of a kernel before it is run; if this prediction is incorrect, these schedulers can default back to their old strategy of measuring the performance on all available accelerators.
<!--However, in this chapter we present a highly accurate predictive framework and discuss the methodology used in its development.
It provides the low-hanging fruit useful in energy-efficient scheduling by providing the initial estimates of execution time and prevents redundant computing work involved in the start-up of new kernels on schedulers.-->
This work was published in the 16^th^ International Conference on High Performance Computing & Simulation, HPCS 2018 [@johnston2018opencl].


## Model Development

This section outlines how AIWC features are used to build a model which accurately predicts the execution times of a previously unencountered OpenCL code over the range of available devices.
The AIWC metrics are generated over the EOD benchmark suite and serve as input variables, while all the execution times presented in Chapter 3 serve as response variables for model training.
The generation of a random forest model was used to learn each machine profile.
This model should be able to offer accurate predictions of execution times based only on the AIWC metrics -- this would be used in the real world by having the trained model available to the scheduler, the AIWC metrics shipped with kernel codes, and the scheduler making accelerator selections entirely by querying the model with these metrics.

We initially performed an evaluation with general linear mixed models but found the random forest model to offer a higher accuracy of predictions.
<!--
The performance predictions from this model may serve as input to scheduling decisions on heterogeneous supercomputing systems.
A major benefit of the predictive model with AIWC approach is that the developer need only instrument a kernel once -- by collecting its AIWC metrics under a realistic workload.
These metrics can be shipped with the source code as a comment or directly in the SPIR.
A further discussion of the computational complexity of running AIWC is discussed in [Section @chapter4-aiwc-limitations].
A scheduler system could be augmented to use the performance model with very low overhead, since querying the model (proposed in this chapter) is computationally inexpensive.
The model need only be retrained when a new accelerator type is added.
-->
The methodology to develop the model is outlined in this section.
All tools used are open source, and all code is available in the respective repositories: [@johnston2017] and [@beau_johnston_2017_1134175].
In the remainder of this section, we outline the experimental setup, describe how the initial predictive model was constructed, examine various optimizations to improve the accuracy of the model and  conclude with a study on how the model performs with unencountered codes.

### Experimental Setup

AIWC -- from Chapter 4 -- was used to characterize a variety of codes in the OpenDwarfs Extended (EOD) Benchmark Suite -- from Chapter 3 -- and the corresponding AIWC metrics were used as predictor variables to fit a random forest regression model.
The metrics were generated over 4 problem sizes for each of the 12 applications / 37 kernels.
Response variables were collected following the same methodology outlined in Chapter 3 -- where the details for each of the applications is also presented.
Execution times were measured for at least 50 iterations and a total runtime of at least two seconds for each combination of device and benchmark.
Each application was run over 15 different accelerator devices and each kernel collected at four different problem sizes.
Our data comprises of 2200+ unique mean runtime entries but when coupled with the AIWC metrics for each observation our data comprises up to 64k entries in total; we train our model with 20% of the data entries (randomly selected) and use the remaining 80% for evaluation.

### Constructing the Random Forest Performance Model

The random forest model is used to estimate the execution times based on the 28 AIWC metrics for all 64k observations.
This regression model uses the measured execution times from EOD as the response and AIWC metrics as predictor variables.
Other predictive models such as linear regression, Principal component regression, generalised linear models, vectorized generalised additive models, however, were discarded due to their multivariate outcomes.
K-nearest neighbours were also considered but the dimensionality of the search-space was too high.
Feed-forward general networks with multiple hidden layers were considered but the sample size was insufficient to ensure valid convergence of the learning function and also the network structure was too simple for the complicated manifold induced by the data.
Random forests were selected since they are a well known robust performer, quick to compute and easy to store the computed object model.
Random forests do not assume any underlying structure in the data but rather finds these automatically using tree pruning methods -- and they are good at segmenting the data for individual regression problems and thus are well suited to our goals; building a performance prediction model that can select between various devices based solely on that kernel's AIWC feature-space.

The R programming language was used to analyse the data, construct the model and analyse the results.
In particular, the \textit{ranger} package by Wright and Ziegler [@JSSv077i01] was used for the development of the regression model. 
The \textit{ranger} package provides computationally efficient implementations of the Random Forest model [@breiman2001random] which performs recursive partitioning of high dimensional data.


<!--see ../analysis_tools/exhaustive_grid_search.R for the implementation -->

The ranger function accepts three main parameters, each of which influences the fit of the model to the data.
In optimizing the model, we searched over a range of values for each parameter including:

* num.trees, the number of trees grown in the random forest: over the range of $10 - 10,000 \text{ by } 500$
* mtry, the number of features tried to possibly split within each node: ranges from $1 - 34$, where $34$ is the maximum number of input features available from AIWC,
* min.node.size, the minimal node size per tree: ranges from $1 - 50$, where $50$ is the number of observations per sample.

Given the size of the data set, it was not computationally viable to perform an exhaustive search of the entire 3-dimensional range of parameters.
Autotuning to determine the suitability of these parameters has been performed by Lie\ss\ et al. [@liess2014sloping] to determine the optimal value of mtry given a fixed num.trees.
Instead, to enable an efficient search of all variables at once, we used Flexible Global Optimization with Simulated-Annealing, in particular, the variant found in the R package \textit{optimization} by Husmann, Lange and Spiegel [@husmannr].
The simulated-annealing method both reduces the risk of getting trapped in a local minimum and is able to deal with irregular and complex parameter spaces as well as with non-continuous and sophisticated loss functions.
In this setting, it is desirable to minimise the out-of-bag prediction error of the resultant fitted model, by simultaneously changing the parameters (num.trees, mtry and min.node.size).
The \textit{optim\_sa} function allows defining the search space of interest, a starting position, the magnitude of the steps according to the relative change in temperature and the wrapper around the ranger function (which parses the 3 parameters and returns a cost function — the predicted error).
It allows for an approximate global minimum to be detected with significantly fewer iterations than an exhaustive grid search.




\begin{figure}[t]
\centering
\includegraphics[width=0.75\columnwidth,keepaspectratio]{./figures/chapter-5/full-variation-in-min-node-size-1.pdf}
\caption{\label{fig:variation-in-min-node-size}Full coverage of min.node.size with fixed tuning parameters: num.trees = 300 and mtry = 30.}
\end{figure}







\begin{figure}[t]
\centering
\includegraphics[width=0.9\columnwidth]{./figures/chapter-5/full-scan-random-sampled-heatmap-1.pdf}
\caption{\label{fig:full-scan-random-sampled-heatmap}Full coverage of num.trees and mtry tuning parameters with min.node.size fixed at 9.}
\end{figure}

Figure \ref{fig:variation-in-min-node-size} shows the relationship between out-of-bag prediction error and min.node.size, with the num.trees = 300 and mtry = 30 parameters fixed.
In general, the min.node.size has the smallest prediction error for values less than 15 and variation in prediction error is similar throughout this range.
As such, the selection to fix min.node.size = 9 was made to reduce the search-space in the remainder of the tuning work.
We assume conditional (relative) independence between min.node.size and the other variables.

Figure \ref{fig:full-scan-random-sampled-heatmap} shows how the prediction error of the random-forest ranger model changes over a wide range of values for the two remaining tuning parameters, mtry and num.trees.
Full coverage was achieved by selecting starting locations in each of the 4 outer-most points of the search space, along with 8 random internal points — to avoid missing out on some critical internal structure.
For each combination of parameter values, the \textit{optim\_sa} function was allowed to execute until a global minimum was found.
At each step of optimization a full trace was collected, where all parameters and the corresponding out-of-bag prediction error value were logged to a file.
This file was finally loaded, the points interpolated using the R package \textit{akima}, without extrapolation between points, using the mean values for duplication between points.
The generated heatmap is shown in Figure \ref{fig:full-scan-random-sampled-heatmap}.

A lower out-of-bag prediction error is better.
For values of mtry above 25, there is a good model fit irrespective of the number of trees.
For lower values of mtry, fit varies significantly with different values of num.trees.
The worst fit was for a model with a value of 1 num.trees, and 1 for mtry, which had the highest out-of-bag prediction error at 194%.
In general, the average prediction error across all choices of parameters is very low at 16%.
Given these results, the final ranger model should use a small value for num.trees and a large value for mtry, with the added benefit that such a model can be computed faster given a smaller number of trees.


### Parameters for the Random Forest Performance Model \label{sec:choosing-model-parameters}

The selected model should be able to accurately predict execution times for a previously unencountered kernel over the full range of accelerators.
To show this, the model must not be over-fitted, that is to say, the random forest model parameters should not be tuned to the particular set of kernels in the training data, but should generate equally good fits if trained on any other reasonable selection of kernels.

We evaluated how robust the selection of model parameters is to the choice of kernel by repeatedly retraining the model on a set of kernels, each time removing a different kernel.
The procedure used is presented in Algorithm \ref{alg:kernel-omission}.
For each selection of kernels, \textit{optima\_sa} was run from the same starting location -- num.trees=500, mtry=32  -- and the final optimal values were recorded. min.node.size was fixed at 9.
The 64k entries are stored in an R data frame -- a table or a two-dimensional array-like structure.

The optimal -- and final -- parameters for each omitted kernel are presented in Table \ref{tab:optimal-tuning-parameters}.
Regardless of which kernel is omitted, the R-squared values -- or explained variance -- is very high at 0.99, indicating a good model fit.
The optimal parameters are very similar regardless of which kernel was omitted.
As such, the median value of each of the parameters was selected for the final model: num.trees = 505, mtry = 30 and min.node.size = 9.
These parameters were used for all further model training.

<!--The remove latexerror is for 2 column ACM format-->
\begingroup
\begin{algorithm}[t]

    \For{each unique kernel}{
        construct a full data frame with all but the current kernel\;
        run optimization \textit{optim\_sa} with the full data frame at selected starting location\;
        record the final optimal parameters
    }
    \caption{\label{alg:kernel-omission}Find the suitability of the optimal parameters for random forest models for future kernels}
\end{algorithm}
\endgroup





\begin{table}[htpb]

\centering
\caption{Optimal tuning parameters from the same starting location for all models omitting each individual kernel.\label{tab:optimal-tuning-parameters}}
\begin{tabular}{@{}cccc@{}}
\toprule

{Kernel omitted} & {num.trees} & {mtry} & \multicolumn{1}{m{2cm}}{\centering prediction error (\%)}\\\hline

invert\_mapping & 521 & 31 & 4.3\\
kmeansPoint & 511 & 30 & 4.1\\
lud\_diagonal & 527 & 29 & 4.4\\
lud\_internal & 488 & 31 & 4.5\\
lud\_perimeter & 480 & 31 & 4.4\\
csr & 507 & 30 & 4.4\\
fftRadix16Kernel & 484 & 29 & 4.4\\
fftRadix8Kernel & 529 & 34 & 4.3\\
fftRadix4Kernel & 463 & 30 & 4.2\\
fftRadix2Kernel & 443 & 28 & 4.4\\
calc\_potential\_single\_step & 502 & 24 & 4.8\\
c\_CopySrcToComponents & 529 & 31 & 4.1\\
cl\_fdwt53Kernel & 499 & 26 & 4.7\\
srad\_cuda\_1 & 504 & 32 & 4.7\\
srad\_cuda\_2 & 500 & 29 & 4.6\\
kernel1 & 536 & 30 & 4.5\\
kernel2 & 469 & 31 & 4.6\\
acc\_b\_dev & 576 & 28 & 4.4\\
calc\_alpha\_dev & 469 & 30 & 4.3\\
calc\_beta\_dev & 498 & 30 & 4.3\\
calc\_gamma\_dev & 517 & 28 & 4.4\\
calc\_xi\_dev & 439 & 33 & 4.3\\
est\_a\_dev & 524 & 30 & 4.2\\
est\_b\_dev & 533 & 28 & 4.3\\
est\_pi\_dev & 450 & 31 & 4.3\\
init\_alpha\_dev & 558 & 32 & 2.6\\
init\_beta\_dev & 467 & 30 & 4.1\\
init\_ones\_dev & 566 & 32 & 4.1\\
mvm\_non\_kernel\_naive & 514 & 30 & 4.3\\
mvm\_trans\_kernel\_naive & 449 & 32 & 4.4\\
scale\_a\_dev & 508 & 31 & 4.3\\
scale\_alpha\_dev & 530 & 30 & 3.8\\
scale\_b\_dev & 565 & 31 & 4.2\\
s\_dot\_kernel\_naive & 509 & 30 & 4.5\\
needle\_opencl\_shared\_1 & 499 & 30 & 4.4\\
needle\_opencl\_shared\_2 & 504 & 29 & 4.5\\
crc32\_slice8 & 511 & 29 & 4.3\\

\hline

\end{tabular}

\end{table}


### Tuning the Random Forest Model \label{sec:finding-the-critical-number-of-kernels}

For a model to be useful in predicting execution times for previously unencountered kernels, it needs to be trained on a representative sample of kernels i.e. a sample that provides good coverage of the AIWC feature space of all possible application kernels.

We measured how model fit improves with the number of kernels used in training, following the method presented in Algorithm \ref{alg:rmse-per-kernel-count}.
The set of unique kernels available during model development is denoted by $k$ (37 kernels in this study), $s$ is the maximum number of sample models (including different combinations of kernels) to evaluate for each number of kernels 1..$|k|$, $\phi$ is a data frame of the combined AIWC feature-space with measured runtime results.
The parameters to the random forest model were fixed at num.trees = 505, mtry = 30 and min.node.size = 9, according to the methodology in Section \ref{sec:choosing-model-parameters}.

<!--The remove latexerror is for 2 column ACM format-->
\begingroup
\newcommand{\isep}{\mathrel{{.}\,{.}}\nobreak}
\begin{algorithm}[t]

    $s \gets 500$\\
    $k \gets $unique(kernel)\\
    \For{$i \gets 1 $\textbf{to} length($k$)}{
        $v_p \gets [ ]$\\
        $v_m \gets [ ]$\\
        \For{$j \gets 1$ \textbf{to} $s$}{
            $x \gets $shuffle($k$)\\
            $y \gets x[1 \isep i]$\\
            \textbf{training data} $\gets$ subset($\phi$, kernel $== y$) \\
            \textbf{test data} $\gets$ subset($\phi$, kernel $!= y$) \\
            discard variables unavailable during real-world training from \textbf{training data} e.g. size, application, kernel name and measured total application time\\
            build ranger model $r$ using \textbf{training data} \\
            generate prediction responses $p$ from $r$ using \textbf{test data}\\
            append predicted execution times $p$ to $v_p$\\
            append measured execution times from \textbf{test data} to $v_m$\\
        }
        compute the mean absolute error $e$ from vector of $p$ relative to vector $m$\\
        store($e$)\\
    }

    \caption{\label{alg:rmse-per-kernel-count}Compute average fit of random forest models trained on different numbers of kernels.}

\end{algorithm}
\endgroup


<!-- see ../analysis_tools/suitable_kernel_counts.R for implementation -->


\begin{figure}[htbp]
\centering
\includegraphics[width=0.6\columnwidth,keepaspectratio]{./figures/chapter-5/rmse_vs_kernel_count-1.pdf}
\caption{\label{fig:rmse-vs-kernel-count}Prediction error across all benchmarks for models trained with varying numbers of kernels.}
\end{figure}


The results presented in Figure \ref{fig:rmse-vs-kernel-count} show the mean absolute error of models trained on varying numbers of kernels.
As expected, the model fit improves with increasing number of kernels.
In particular, larger improvements occur with each new kernel early in the series and tapers off as a new kernel is added to an already large number of kernels.
The gradient is still significant until the largest number of samples examined ($k=37$) suggesting that the model could benefit from additional training data.
However, the model proposed is a proof of concept and suggests that a general purpose model is attainable and may not require many more kernels.


## Evaluation




\begin{figure}[htbp]
\centering
%acm
\includegraphics[width=0.6\columnwidth]{./figures/chapter-5/actual-vs-predicted-size-plot-1.pdf}
\caption{\label{fig:selected-model-actual-vs-predicted-times}Predicted vs. measured execution time (in log(\textmu s)) for all kernels}
\end{figure}

Figure \ref{fig:selected-model-actual-vs-predicted-times} presents the measured kernel execution times (in log(\textmu s)) against the predicted execution times from the trained model.
Each point represents a single combination of kernel and problem size -- there are 64k points in total.
The plot shows a strong linear correlation indicating a good model fit.
Under-predictions typically occur on four kernels over the medium and large problem sizes, while over-predictions occur on the tiny and small problem sizes.
However, these outliers are visually over-represented in this figure as the final mean absolute error is low, at ~0.1.


### Predicting Kernel Execution Time

In this section, we examine differences in the accuracy of predicted execution times between different kernels, which is of importance if the predictions are to be used in a scheduling setting.

<!--fig.height=11.7-->




\begin{figure*}
\centering
\includegraphics[width=\linewidth]{./figures/chapter-5/predictive-heatmap-percentage-1.pdf}
\caption{\label{fig:predictive-heatmap-percentage}Error in predicted execution time for each kernel invocation over four problem sizes}
\end{figure*}


The four heat maps presented in Figure \ref{fig:predictive-heatmap-percentage} show the difference between mean predicted and measured kernel execution times as a percentage of the measured time.
Thus, they depict the relative error in prediction -- lighter indicates a smaller error.
Four different problem sizes are presented: tiny in the top-left, small in the top-right, medium bottom-left, large bottom-right.
The kernels (y-axis) between each of problem size do not align due to the number of supported applications, and kernels, in each problem size -- this is discussed in Chapter 3.

In general, we see highly accurate predictions which on average differ from the measured experimental run-times by 1.1%, which correspond to actual execution time mispredictions of 8 \textmu s to 1s according to problem size.

The `init_alpha_dev` kernel is the worst predicted kernel over both the tiny and small problem sizes, with mean misprediction at 7.6%.
However, this kernel is only run once per application run -- it is used in the initialization of the Hidden Markov Model -- and as such there are fewer samples available to influence the model, this may lead its poorer predictions.

<!--
However this could be systematic of the i5 processor having the lowest clock speed, as such the model misprediction is the same but the execution results are magnified.
-->

### Choosing The Optimal Accelerator for a Kernel



\begin{figure*}
\centering
\includegraphics[width=\linewidth]{./figures/chapter-5/large-predicted-vs-measured-1.pdf}
\caption{\label{fig:large-predicted-vs-measured}Mean measured kernel execution times compared against mean predicted kernel execution times to perform a selection of kernels on large problem sizes across 15 accelerator devices. The square indicates the mean measured time, and the diamond indicates the mean predicted time.}
\end{figure*}


To demonstrate the utility of the trained model to guide scheduling choices, we focus on the accuracy of performance time prediction of individual kernels over all devices.
The model performance in terms of real execution times is presented for four  selected kernels in Figure \ref{fig:large-predicted-vs-measured}.
The shape denotes the type of execution time data point, a square indicates the mean measured time, and the diamond indicates the predicted time.
Thus, a perfect prediction occurs where the measured time -- square -- fits perfectly within the predicted -- diamond -- as shown in the legend.

The purpose of showing these results is to highlight the setting in which they could be used -- on the supercomputing node.
In this instance, it is expected a node to be composed of any combination of the 15 devices presented in the Figure \ref{fig:large-predicted-vs-measured}.
Thus, to be able to advise a scheduler which device to use to execute a kernel, the model must be able to correctly predict on which of a given pair of devices the kernel will run fastest.
For any selected pair of devices, if the relative ordering of the measured and predicted execution times is different, the scheduler would choose the wrong device.
In almost all cases, the relative order is preserved using our model.
In other words, our model will correctly predict the fastest device in all cases -- with one exception, the `kmeansPoint` kernel.
For this kernel, the predicted time of the fiji-furyx is lower than the hawaii-r9-290x, however the measured times between the two shows the furyx completing the task in a shorter time.
For all other device pairs, the relative order for the `kmeansPoint` kernel is correct.
Additionally, the `lud_diagonal` kernel suffers from systematic under-prediction of execution times on AMD GPU devices, however, the relative ordering is still correct.
As such, the proposed model provides sufficiently accurate execution time predictions to be useful for scheduling to heterogeneous compute devices on supercomputers.

<!--
### Scheduling Varied Workloads on Heterogeneous HPC Systems
The cost of making a prediction is $\approx 834$ms on the analysis system (i7-6700k and 16GB RAM) and is queried using \textit{R}.
While the time taken is comparable to executing the kernel directly on a device, our strategy avoids the startup time associated with setting up the device, memory objects and kernel compilation and execution in OpenCL which is orders of magnitude slower, and avoids potential variation between runs -- a large sample size was used to predict mean execution times.
Also, this is a prototype and the '\textit{predict}' function itself can likely be made much faster with an optimized `C` implementation instead of being called from \textit{R}.
'\textit{predict}' is a generic function for predictions from the results of various model fitting functions.
The training is significantly more expensive to run, ranging from seconds to several minutes depending on the amount of data; thankfully, this only need be performed when new runtime data are provided -- which is only needed once a new accelerator is provided.
It is envisaged that a pre-trained model can be shipped to HPC nodes for a scheduler to make the most appropriate predictions.

We now illustrate how our prediction methodology can be used with an example.
A developer is working on a quantum chemistry package.
This is a very large package with millions of lines of code.
It includes parts which run on accelerators -- which for the point of this argument is written in OpenCL.
The OpenCL kernels are not part of the EOD benchmark suite nor is it classified in terms of the Berkeley dwarf taxonomy.
The developer runs AIWC on the package with a small subset of the problem.
AIWC metrics are collected and embedded in each of these kernels.
Then in order to direct OpenCL kernels to the optimal device, the developer would load the embedded AIWC metrics for that kernel into R and run the '\textit{predict}' function on all potential accelerator devices. 
The optimal selection would be the device with the lowest predicted execution time.
Ideally, this task of selecting the most appropriate device could be moved into work done by the scheduler -- at a node level.
An example of this approach -- making predictions with AIWC features -- is provided in Jupyter.\footnote{https://github.com/BeauJoh/opencl-predictions-with-aiwc}
-->


##Discussion

The AIWC metrics generated from the full set of Extended OpenDwarfs kernels are used as input variables in a regression model to predict kernel execution time on each device [@johnston2018opencl].
From the accuracy of these predictions, we can conclude that while our choice of AIWC metrics is not necessarily optimal, they are sufficient to characterize the behaviour of OpenCL kernel codes and identify the optimal execution device for a particular kernel.
The model predictions differed from the measured experimental results by an average of 1.1%, which corresponds to the actual execution time mispredictions of 8\textmu s to 1s according to problem size.

There are limitations of the random forest model for extrapolation of data.
Namely, if you have different kernels then you are going to need to collect lots of data concerning the performance of these kernels and then re-fit the random forest model again.
This is not very efficient to have to re-train but if you don't then there is a strong risk of poor prediction.
Other approaches are more robust in this situation.

Other potential critiques of using the random forest for this problem include the potential for comparatively large model storage as dimensionality increases, and that there is no feedback from the model as to why a particular device choice is optimal. The metrics used in the assessment are quite limited and more detailed error investigation analysis could include confidence scores or uncertainty on the predictions based on a more comprehensive error analysis which explores the levels of prediction uncertainty associated with each kernel.

If the predictive model were used in a real-world setting -- say on an HPC system -- the final metrics collected by AIWC could be embedded as a comment at the beginning of each kernel code.
This would follow the use-case for AIWC as a plugin to the OpenCL debugger Oclgrind.
The developer would first use Oclgrind to debug, optimize and confirm functionality of a kernel, then, enable the AIWC plugin to generate the metrics for the final kernel code with the program settings that will be used at runtime.
Our proposed solution uses AIWC as a plugin to the Oclgrind tool, which is already widely used by OpenCL developers.
These metrics are included as a comment into the kernel -- either in source or SPIR form.
The scheduler extracts these metrics at runtime and evaluates them with the model to make performance predictions on the available devices (if the runtime settings lead to substantially different AIWC features to the ones collected than the runtimes predictions may be inaccurate).
This approach would allow the high accuracy of the predictive model without any significant overhead -- metrics are only generated and embedded once per kernel and is done largely automatically, with the guidance of the developer.
<!--StarPU [@augonnet2011starpu], Ompss [@duran2011ompss] and CoreTSAR [@scogland2014coretsar] schedulers could incorporate this prediction methodology to provide the initial estimate of a kernel's execution time or energy usage without having to first execute it on all accelerators -- the strategy historically employed.-->
The training of the model would only need to occur when the HPC system is updated, such that, a new accelerator device is added, or the drivers, or compiler updated.
The extent of model training is also largely automatic following the methodology presented in this thesis: EOD is run over updated devices and the performance runtimes provided into a newly trained regression model.

The predictive model can choose the most appropriate accelerator for a given kernel.
Given a workload of varied applications, execution time predictions can be used to choose which nodes to allocate for each application.
The execution time predictions can be used to determine whether to migrate applications between nodes e.g. when new nodes become available.

AIWC and the prediction methodology could also be used to guide system designers on the optimal mix of accelerators for future supercomputers.
For instance, the range of codes expected to run on the machine can be examined with AIWC before any hardware is purchased.
The predictive model can be trained by the hardware vendor using EOD (or other benchmark suites) and the trained model can be used by an HPC facility owner to predict the performance of their own suite of codes, without the need to provide the characteristics of these codes to the vendor.

