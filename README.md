Intern-Project

My own project while doing internship in simulmedia

Kantar Cost Estimates
============================
Author: Rui Fan

Contact: rf2546@tc.columbia.edu

Please read me before checking and running files

## How To Use These Files

* The files that include '*' in its name are some reference files or scripts. These scripts represent some of the author's thoughts when conducting the project. So there is no need to run these files rather than just take a look at them.
* The Unload data file indicates how to extract the data. We want to extract two sets of data, one set extracts 'program' and the other extracts 'program_type'. Note that in both dataset, we would like to explore the ads with cost greater than 0.
* The data visualization file gives you a brief understanding of how variables influence the cost of ad
* There are two modeling files, one is R file and the other is python file. For R file, two average methods are shown. For python file, regression tree, random forest, k-nn regression, lasso regression are conducted. All of the methods are evaluated by 10-cross-validated mean percent absolute error

## How To Run
* Unload data to S3 and download them into local direction - Unload the data in the most recent 6 months that have cost records(as training set) and the data that doesn't have cost records(as testing set)
* Conduct Regression tree on the training set
* Fit the model on testing set, here we have the predited cost of ad

## What Should Do Next
* Since the data is so large even doing regression tree on it is time comsuming. So we need to deal with this problem:
 * The first way is to try dimention rediction, like PCA, feature selection or other methods.
 * The second way might want to fit the model on a rather shorter date range. May be we can use the most recent two or three months data as training data.
