Feedback:
--------

- Fix bibliography to use anuthesis-theme -- see good-sample.pdf
- what good theses have you read? what features of their abstracts/intros would you like to reflect in your own?

#Abstract

- currently reads like three abstracts pasted together. Try to make it read like a single coherent body of work. One possible structure to follow: Problem-Insight/Contribution-Results-Significance
- mix between passive/third-person and active/first-person: be really clear about what are your contributions
- what is/are your key insight/s? I.e. a statement that is interesting, not obviously true, but well-supported by your research findings

- more details of OpenCL and heterogeneous HPC
- absolute error in predictions is meaningless without knowing the total runtime - maybe just stick to relative errors

#Intro

- Contributions: Try to make broader claims, e.g. "The first-the only-the most comprehensive". For example, "A benchmark suite is extended to include a greater range of scientific applications and over a differing problem sizes." - why is this important? What makes your extended benchmark suite the best in some respect?
- AIWC: diversity analysis - what does this mean? how is it demonstrated in the thesis?
- Does a "scientific hardware agnostic code" exist? Are you confident to claim that OpenCL is hardware agnostic? (Several reviewers have said otherwise.)
- try to use fewer linking introductory words like "Independently,/Additionally,/Separately,/Further," - they don't add anything to the meaning


#Background work

- I haven't read this in detail yet, but at a glance it looks like much more detail is required on accelerator architectures - in particular, the features of different accelerator types that make performance prediction and scheduling challenging.


Done
----

#Abstract

- "A thesis [submitted] for the degree..."
- do you have the ANU CS thesis template? This has good defaults for section numbers, font size, margins, etc.
- spelling of heterogeneous

#Introduction

- ODE: this acronym is already taken for scientific computing. Maybe use EOD
- to start: step back: why is heterogeneity beneficial in HPC?
- (throughout) next generation of supercomputers, or current generation? Summit is live!
- "the characteristics of a scientific code, specifically around computation, memory, branching and parallelism, are independent of any particular device on which they may be finally executed ... regardless of problem size" - is this true of the AIWC metrics, including all the memory metrics? -- YES!
- random forest is not a focus of the thesis (and anyway, isn’t it mostly Greg's contribution?)
- "complicates the already complicated issue"
- the last sentence of the third paragraph is a return to stating the problem. It should probably be part of the first paragraph.

After Thesis Draft
------------------

*   Journal article for benchmarking
*   Journal article for AIWC
*   Journal article for prediction -- with scheduling

