#Finding the Features of a Dwarf

This chapter focuses on generating the feature-space representation of a dwarf.
The methodology starts by reproducing the results shown in established literature -- using Microarchitectural hardware counters followed by principal component analysis, and compares these results to the newly generated feature-spaces using simulator instrumentation tools.

The results presented are used to evalute the sub-questions regarding:

* *Does Phase-Shifting occur within OpenCL kernels?*
* *Are the principal components used when performing microarchitecture independent analysis transferable to architecture independent analysis.*
* *How is the feature space generated from instrumentation tools -- such as `oclgrind` -- comparable to those generated from hardware monitoring processes -- namely PIN. Is it more accurate or applicable to the OpenCL platform.*
* *In what ways does incorrectly setting tuning arguments and compiler flags effect the features-space of an OpenCL kernel?*

#Application-Accelerator Prediction

This Chapter uses the performance results presented in Chapter 4 and the feature-spaces presented in Chapter 5 to develop a model.
The feature-space first undergoes a reduction to simplify the space from the application domain to one focused on the superset of applications -- dwarfs.
This model is then used to predict an optimal accelerator type for new OpenCL kernels, ones unused for the model development.
The evaluation of this model is presented and the corresponding feasibility addresses the primary question raised by this thesis, namely: *Can the structure of OpenCL kernels be used determine the type of accelerator on which it should be run?*


