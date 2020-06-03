
<!-- README.md is generated from README.Rmd. Please edit the latter. -->

## capeml: tools to aid the generation of EML metadata

### overview

This package contains tools to aid the generation of EML metadata with
intent to publish a data set (data + metadata) in the Environmental Data
Initiative (EDI) data repository. Functions and a workflow are included
that allow for the creation of metadata at the dataset level, and
individual data entities (e.g., other entities, data tables).

Helper functions for the creation of dataset metadata, `dataTable()`,
and `otherEntity()` entities using the
[EML](https://docs.ropensci.org/EML/) package are supported. This
package can be extended with the
[capemlGIS](https://github.com/CAPLTER/capemlGIS) package to generate
metadata for `spatialRaster()` and `spatialVector()` entities.

Note that the creation of people-related entities in EML are specific to
functions that rely on Global Institute of Sustainability
infrastructure; please see the
[gioseml](https://github.com/CAPLTER/gioseml) package for these tools.

A template workflow to generating a complete EML record is included with
this package:
[knb-lter-cap.xxx.Rmd](https://github.com/CAPLTER/capeml/blob/master/knb-lter-cap.xxx.Rmd).

### installation

Install from GitHub (after installing the
[devtools](https://cran.r-project.org/web/packages/devtools/index.html)
package:

``` r
devtools::install_github("CAPLTER/capeml")
```

#### options

##### EML

This package defaults to the current version of EML. If desired, users
can switch to the previous version with
`emld::eml_version("eml-2.1.1")`.

##### project naming

Most EML-generating functions in the capeml package will create both
physical objects and EML references to those objects with the format:
`project-id`\_`object-name`\_`object-hash`.`file-extension` (e.g.,
*664\_site\_map\_5fb7b8d53d48010eab1a2e73db7f1941.png*). The target
object (e.g., site\_map.png from the previous example) is renamed with
the additional metadata and this object name is referenced in the EML
metadata. The only exception to this approach are spatialVectors where
the hash of the file/object is not included in the new object name. Note
that the project-id is not passed to any of the functions, and must
exist in the working R environment (as `projectid`).

Project-naming functionality can be turned off by setting the
`projectNaming` option in `create_dataTable()`,
`create_spatialRaster()`, `create_spatialVector()`, and
`create_otherEntity()` to FALSE. When set to FALSE, the object name is
not changed, and the file name of the object is included in the EML.

#### tools to generate entity metadata

  - `write_attributes()` creates a template as a csv file for supplying
    attribute metadata for a tabular data object that resides in the R
    environment
  - `write_factors()` creates a template as a csv file for supplying
    code definition metadata for factors in a tabular data object that
    resides in the R environment

#### tools to create EML entities

  - `create_dataTable()` creates a EML entity of type dataTable
  - `create_otherEntity()` creates a EML entity of type otherEntity

#### construct a dataset

##### abstract

The `create_dataset` function will look for a `abstract.md` file in the
working directory or at the path provided if specified. `abstract.md`
must be a markdown file.

##### keywords

`write_keywords()` creates a template as a csv file for supplying
dataset keywords. The `create_dataset` function will look for a
`keywords.csv` file in the working directory or at the path provided if
specified.

##### methods

The `create_dataset` function will look for a `methods.md` file in the
working directory or at the path provided if specified (`methods.md`
must be a markdown file.). Alternatively, the workflow below is an
enhanced approach of developing methods if provenance data are required
or there are multiple methods files.

``` r
library(EDIutils)

# methods from file tagged as markdown
main <- read_markdown("~/Dropbox/development/knb-lter-cap.683/methods.md")

# provenance: naip
naip <- emld::as_emld(EDIutils::api_get_provenance_metadata("knb-lter-cap.623.1"))
naip$`@context` <- NULL
naip$`@type` <- NULL

# provenance: lst
lst <- emld::as_emld(EDIutils::api_get_provenance_metadata("knb-lter-cap.677.1"))
lst$`@context` <- NULL
lst$`@type` <- NULL

enhancedMethods <- EML::eml$methods(methodStep = list(main, naip, lst))
```

##### coverages

*Geographic* and *temporal* coverages are straight foward and documented
in the workflow, but creating a *taxonomic* coverage is more involved.
*Taxonomic coverage(s)* are constructed using EDI’s
[taxonomyCleanr](https://github.com/EDIorg/taxonomyCleanr) tool suite.

A sample workflow for creating a taxonomic coverage:

``` r
library(taxonomyCleanr)

my_path <- getwd() # taxonomyCleanr requires a path (to build the taxa_map)

# Example: draw taxonomic information from existing resource:

# plant taxa listed in the om_transpiration_factors file
plantTaxa <- read_csv('om_transpiration_factors.csv') %>% 
  filter(attributeName == "species") %>% 
  as.data.frame()

# create or update map. A taxa_map.csv is the heart of taxonomyCleanr. This
# function will build the taxa_map.csv and put it in the path identified with
# my_path.
create_taxa_map(path = my_path, x = plantTaxa, col = "definition") 

# Example: construct taxonomic resource:

gambelQuail <- tibble(taxName = "Callipepla gambelii")

# Create or update map: a taxa_map.csv is the heart of taxonomyCleanr. This
# function will build the taxa_map.csv in the path identified with my_path.
create_taxa_map(path = my_path, x = gambelQuail, col = "taxName") 

# Resolve taxa by attempting to match the taxon name (data.source 3 is ITIS but
# other sources are accessible). Use `resolve_comm_taxa` instead of
# `resolve_sci_taxa` if taxa names are common names but note that ITIS
# (data.source 3) is the only authority taxonomyCleanr will allow for common
# names.
resolve_sci_taxa(path = my_path, data.sources = 3) # in this case, 3 is ITIS

# build the EML taxonomomic coverage
taxaCoverage <- make_taxonomicCoverage(path = my_path)

# add taxonomic to the other coverages
coverage$taxonomicCoverage <- taxaCoverage
```

#### overview: create a dataTable

Given a rectangular data matrix of type dataframe or Tibble in the R
environment:

`write_attributes(data_entity)` will generate a template as a csv file
in the working directory based on properties of the data entity such
that metadata properties (e.g., attributeDefinition, units) can be added
via a editor or spreadsheet application.

`write_factors(data_entity)` will generate a template as a csv file in
the working directory based on columns of the data entity that are
factors such that details of factor levels can be added via a editor or
spreadsheet application.

`create_dataTable(data_entity)` performs many services:

  - the data entity is written to file as a csv in the working directory
    with the file name:
    *projectid\_data-entity-name\_md5-hash-of-file.csv*
  - metadata provided in the attributes and factors (if relevant)
    templates are ingested
  - a EML object of type dataTable is returned
  - note that the data entity name should be used consistently within
    the chunk, and the resulting dataTable entity should have the name:
    *data\_entity\_DT*

#### overview: create a otherEntity

A EML object of type otherEntity can be created from a single file or a
directory. In the case of generating a otherEntity object from a
directory, pass the directory path to the targetFile argument, capeml
will recognize the target as a directory, and create a zipped file of
the identified directory.

If the otherEntity object already is a zip file with the desired name,
set the overwrite argument to FALSE to prevent overwriting the existing
object.

As with all objects created with the capeml package, the resulting
object is named with convention:
projectid\_object-name\_md5sum-hash.file extension by default but this
functionality can be turned off by setting projectNaming to FALSE.

#### literature cited

Though not provided as a function, below is a workflow for adding
literature cited elements at the dataset level. The workflow capitalizes
on EML version 2.2 that accepts the BibTex format for references.

``` r
# add literature cited if relevant
library(rcrossref)
library(EML)

mccafferty <- cr_cn(dois = "https://doi.org/10.1186/s40317-015-0075-2", format = "bibtex")
mccaffertycit <- EML::eml$citation(id = "https://doi.org/10.1186/s40317-015-0075-2")
mccaffertycit$bibtex <- mccafferty 

citations <- list(
  citation = list(
    mccaffertycit
  ) # close list of citations
) # close citation

dataset$literatureCited <- citations 
```
