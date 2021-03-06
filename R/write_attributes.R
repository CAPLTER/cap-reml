#' @title write_attributes
#'
#' @description write_attributes creates a template as a yaml file for
#'   supplying attribute metadata for a tabular data object that resides in the R
#'   environment.
#'
#' @details The yaml template generated by write_attributes includes the field
#'   names of the data entity. The number type, column class (e.g., factor,
#'   numeric), minimum and maximum values (if numeric), and missing value code
#'   and explanation (if provided) for each field. The template supports input of
#'   format string, unit, definition, and attribute definition. The yaml file is
#'   written with the name of the data object in R + "_attrs". The
#'   create_dataTable function will search for this file will creating a EML
#'   dataTable entity.
#'
#' @param dfname
#'  (character) Unquoted name of the R data frame or tibble.
#' @param overwrite
#'  (logical) Logical indicating if an existing attributes file in the target
#'  directory should be overwritten.
#'
#' @import dplyr
#' @import yaml
#' @importFrom purrr map_chr map2
#' @importFrom sf st_drop_geometry
#' @importFrom stats na.omit
#' @importFrom lubridate is.POSIXt is.POSIXlt is.POSIXct
#'
#' @return The name of the file generated is returned, and a template for
#'   providing attribute metadata as a yaml file with the file name of the R data
#'   object + "_attrs.yaml" is created in the working directory.
#'
#' @examples
#' \dontrun{
#'
#'  write_attributes(R data object)
#'
#'  # overwrite existing attributes file
#'  write_attributes(dfname = R data object,
#'                   overwrite = TRUE)
#'
#' }
#'
#' @export

write_attributes <- function(dfname, overwrite = FALSE) {

  # establish yaml object name for checking if exists and writing to file
  objectName <- paste0(deparse(substitute(dfname)), "_attrs")
  fileName <- paste0(objectName, ".yaml")


  # check if attributes already exists for given data entity
  if (file.exists(fileName) && overwrite == FALSE) {

    stop(
      paste0("file ", fileName, " already exists, use write_attributes(overwrite = TRUE) to overwrite")
    )

  }


  # helper function to check the class of a variable; the column class of a
  # spatial file can be a vector so pull the first entity only
  check_class <- function(x) { class(x)[[1]] }


  # if simple features, do not write include geometry column(s)
  if (class(dfname)[[1]] == "sf") {

    dfname <- dfname %>%
      sf::st_drop_geometry()

  }


  # helper function to get the type of numeric variables
  get_number_type <- function(x) {

    raw <- na.omit(x)
    raw <- raw[is.finite(raw)] # remove infs (just in case)

    rounded <- floor(raw)

    if (length(raw) - sum(raw == rounded, na.rm = TRUE) > 0) {

      numType <- "real" # all

    } else if (min(raw, na.rm = T) > 0) {

      numType <- "natural" # 1, 2, 3, ... (sans 0)

    } else if (min(raw, na.rm = T) < 0) {

      numType <- "integer" # whole + negative values

    } else {

      numType  <- "whole" # natural + 0

    }

    return(numType)

  }


  # construct yaml entry for each variable
  attributes_to_yaml <- function(variable, varName) {

    variableAttributes <- list(
      attributeName = varName,
      attributeDefinition = ""
    )

    if (is.numeric(variable)) {

      variableAttributes <- c(
        variableAttributes,
        unit = "",
        numberType = get_number_type(variable),
        minimum = min(variable, na.rm = TRUE),
        maximum = max(variable, na.rm = TRUE)
      )

      if (is.integer(variable)) {

        variableAttributes <- c(
          variableAttributes,
          columnClasses = "numeric"
        )

      } else {

        variableAttributes <- c(
          variableAttributes,
          columnClasses = check_class(variable)
        )

      }

    } else if (is.character(variable)) {

      variableAttributes <- c(
        variableAttributes,
        columnClasses = check_class(variable),
        definition = ""
      )

    } else if (is.factor(variable)) {

      variableAttributes <- c(
        variableAttributes,
        columnClasses = check_class(variable)
      )

    } else if (
      lubridate::is.Date(variable) |
        lubridate::is.POSIXt(variable) |
        lubridate::is.POSIXlt(variable) |
        lubridate::is.POSIXct(variable)
      ) {

      variableAttributes <- c(
        variableAttributes,
        # columnClasses = check_class(variable),
        columnClasses = "Date",
        formatString = "YYYY-MM-DD"
      )

    } else {

      stop("dataframe has a variable for which the class could not be determined")

    }

    return(variableAttributes)

  }


  # build attribute yaml file
  attributeYaml <- yaml::as.yaml(
    map2(
      .x = dfname,
      .y = colnames(dfname),
      .f = attributes_to_yaml)
  )

  # write attribute yaml to file
  yaml::write_yaml(
    x = attributeYaml,
    file = fileName
  )

  message(paste0("constructed attribute yaml: ", fileName))

  return(objectName)

}
