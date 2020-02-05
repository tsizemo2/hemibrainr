<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<img src="man/figures/logo.svg" align="right" height="139" />
<!-- badges: end -->

hemibrainr
==========

The goal of *hemibrainr* is to provide useful code for preprocessing and
analysing data from the [Janelia FlyEM
hemibrain](https://www.janelia.org/project-team/flyem) project. It makes
use of the [natverse](https://github.com/natverse) R package,
[neuprintr](https://github.com/natverse/neuprintr) to get hemibrain data
from their connectome analysis and data hosting service
[neuprint](https://github.com/connectome-neuprint/neuPrint). The dataset
has been described
[here]((https://www.biorxiv.org/content/10.1101/2020.01.21.911859v1)).
Using this R package in concert with the
[natverse](https://github.com/natverse/natverse) ecosystem is highly
recommended.

Tutorial
--------

To help you get to grips with `neuprintr`, we have made a tutorial in
classic presentation form. This tutorial uses data from the [Janelia Fly
EM](https://www.janelia.org/project-team/flyem) team’s
[hemibrain](https://www.biorxiv.org/content/10.1101/2020.01.21.911859v1)
project. You can also see the vignettes in this package for the same
examples and more.

Installation
------------

``` r
# install
if (!require("remotes")) install.packages("remotes")
remotes::install_github("flyconnectome/hemibrainer")

# use 
library(hemibrainr)
```

Authentication
--------------

In order to use *neuprintr*, which fetches data we want to use with
*hemibrainr*, you will need to be able to login to a neuPrint server and
be able to access it underlying Neo4j database.

You may need an authenticated accounted, or you may be able to register
your `@gmail` address without an authentication process. Navigate to a
neuPrint website,
e.g. <a href="https://neuprint.janelia.org" class="uri">https://neuprint.janelia.org</a>,
and hit ‘login’. Sign in using an `@gmail` account. If you have
authentication/the server is public, you will now be able to see your
access token by going to ‘Account’:

![access your bearer
token](https://raw.githubusercontent.com/natverse/neuprintr/master/inst/images/bearertoken.png)

To make life easier, you can then edit your `.Renviron` file to contain
information about the neuPrint server you want to speak with, your token
and the dataset hosted by that server, that you want to read. A
convenient way to do this is to do

``` r
usethis::edit_r_environ()
```

and then edit the file that pops up, adding a section like

``` r
neuprint_server="https://neuprint.janelia.org"
# nb this token is a dummy
neuprint_token="asBatEsiOIJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImIsImxldmVsIjoicmVhZHdyaXRlIiwiaW1hZ2UtdXJsIjoiaHR0cHM7Ly9saDQuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1QeFVrTFZtbHdmcy9BQUFBQUFBQUFBDD9BQUFBQUFBQUFBQS9BQ0hpM3JleFZMeEI4Nl9FT1asb0dyMnV0QjJBcFJSZlI6MTczMjc1MjU2HH0.jhh1nMDBPl5A1HYKcszXM518NZeAhZG9jKy3hzVOWEU"
neuprint_dataset = "hemibrain:v1.0.1"
```

Make sure you have a blank line at the end of your `.Renviron` file. For
further information try about neuprintr login, see the help for
`neuprint_login()`.

Finally you can also login on the command line once per session, like
so:

``` r
conn = neuprint_login(server= "https://neuprint.janelia.org/",
   token= "asBatEsiOIJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImIsImxldmVsIjoicmVhZHdyaXRlIiwiaW1hZ2UtdXJsIjoiaHR0cHM7Ly9saDQuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1QeFVrTFZtbHdmcy9BQUFBQUFBQUFBDD9BQUFBQUFBQUFBQS9BQ0hpM3JleFZMeEI4Nl9FT1asb0dyMnV0QjJBcFJSZlI6MTczMjc1MjU2HH0.jhh1nMDBPl5A1HYKcszXM518NZeAhZG9jKy3hzVOWEU")
```

This is also the approach that you would take if you were working with
more than two neuPrint servers.

Example
-------

Now we can have a look at what is available

``` r
# What data sets are available?
neuprint_datasets()

# What's the underlying database
neuprint_database()

# What are the regions of interrst in your default datasest (specified in R.environ, see ?neuprint_login)
neuprint_ROIs()
```

Use the client to request data from neuprint. The
`neuprint_fetch_custom` method will run an arbitrary cypher query
against the database. For information about the neuprint data model, see
the neuprint explorer web help:
<a href="https://neuprint.janelia.org/help" class="uri">https://neuprint.janelia.org/help</a>.

Some cyphers and other API endpoints have been explored by this package.
Have a look a the functions, for example, that give you neuron
skeletons, synapse locations, connectivity matrices, etc.

``` r
?neuprint_search
?neuprint_get_adjacency_matrix
?neuprint_ROI_connectivity
?neuprint_get_synapses
?neuprint_read_neurons
```

Data
----

-   HemiBrain (hemibrain:v1.0) : from [“A Connectome of the Adult
    Drosophila Central
    Brain”](https://www.biorxiv.org/content/10.1101/2020.01.21.911859v1)
    (Xu, et al. 2020)

Acknowledging the tools
-----------------------

neuPrint comprises a set of tools for loading and analyzing connectome
data into a Neo4j database. Analyze and explore connectome data stored
in Neo4j using the neuPrint ecosystem:
[neuPrintHTTP](https://github.com/connectome-neuprint/neuPrintHTTP),
[neuPrintExplorer](https://github.com/connectome-neuprint/neuPrintExplorer),
[Python API](https://github.com/connectome-neuprint/neuprint-python).

This package was created by [Alexander Shakeel
Bates](https://scholar.google.com/citations?user=BOVTiXIAAAAJ&hl=en) and
[Gregory Jefferis](https://en.wikipedia.org/wiki/Gregory_Jefferis). You
can cite this package as:

``` r
citation(package = "hemibrainr")
```

**Bates AS, Jefferis GSXE** (2020). *hemibrainr: Code for working with
data from Janelia FlyEM’s hemibrain project.* **R package** version
0.1.0.
<a href="https://github.com/natverse/neuprintr" class="uri">https://github.com/natverse/neuprintr</a>
