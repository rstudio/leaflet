We welcome contributions to the **leaflet** package!

To submit a contribution:

1. [Fork](https://github.com/rstudio/leaflet/fork) the repository and make your changes.

2. Ensure that you have signed the [individual](https://rstudioblog.files.wordpress.com/2017/05/rstudio_individual_contributor_agreement.pdf) or [corporate](https://rstudioblog.files.wordpress.com/2017/05/rstudio_corporate_contributor_agreement.pdf) contributor agreement as appropriate. You can send the signed copy to jj@rstudio.com.

3. Submit a [pull request](https://help.github.com/articles/using-pull-requests).

We generally do not merge pull requests that update included web libraries (such as Bootstrap or jQuery) because it is difficult for us to verify that the update is done correctly; we prefer to update these libraries ourselves.


## How to make changes

Before you submit a pull request, please do the following:

* Add an entry to NEWS concisely describing what you changed.

* If appropriate, add unit tests in the tests/ directory.

* Run Build->Check Package in the RStudio IDE, or `devtools::check()`, to make sure your change did not add any messages, warnings, or errors.

Doing these things will make it easier for the leaflet development team to evaluate your pull request. Even so, we may still decide to modify your code or even not merge it at all. Factors that may prevent us from merging the pull request include:

* breaking backward compatibility
* adding a feature that we do not consider relevant for leaflet
* is hard to understand
* is hard to maintain in the future
* is computationally expensive
* is not intuitive for people to use

We will try to be responsive and provide feedback in case we decide not to merge your pull request.


## Filing issues

If you find a bug in leaflet, you can also [file an issue](https://github.com/rstudio/leaflet/issues/new). Please provide as much relevant information as you can, and include a minimal reproducible example if possible.
