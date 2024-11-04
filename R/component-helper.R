.isReactive <- function(x) {
  return(inherits(x, "reactive"))
}

.checkReactive <- function(x) {
  if (!.isReactive(x)) "Must be a reactive object" else TRUE
}

.assertReactive <- function(x, .var.name = checkmate::vname(x), add = NULL) {
  res <- .checkReactive(x)
  checkmate::makeAssertion(x, res, .var.name, add)
}


.reconcileFunctionFormals <- function(fun,
                                      aList = NULL,
                                      warnOnExtraArgs = FALSE,
                                      replaceNullValuesWithDefault = TRUE) {

  if (is.null(aList)) {
    return(formals(fun))
  }

  assertCollection <- checkmate::makeAssertCollection()
  checkmate::assertFunction(fun, add = assertCollection)
  checkmate::assertList(aList, add = assertCollection)
  checkmate::assertLogical(warnOnExtraArgs, add = assertCollection)
  checkmate::assertLogical(replaceNullValuesWithDefault, add = assertCollection)
  checkmate::reportAssertions(collection = assertCollection)

  funFormals <- formals(fun)
  funFormalNames <- names(funFormals)

  missingArgs <- setdiff(funFormalNames, names(aList))
  sharedArgs <- intersect(funFormalNames, names(aList))

  # Replace NULL values passed where default is not null
  if (replaceNullValuesWithDefault) {
    for (arg in sharedArgs) {
      if (is.null(aList[[arg]]) && !is.null(funFormals[[arg]])) {
        aList[[arg]] <- funFormals[[arg]]
      }
    }
  }


  # Populate unspecified arguments
  missingArgs <- sapply(missingArgs,
                        FUN = function(arg) { return(funFormals[[arg]]) })
  aList <- c(aList, missingArgs)


  if (warnOnExtraArgs) {
    extraArgs <- setdiff(names(aList), funFormalNames)
    if (length(extraArgs) > 0)
      warning(sprintf("Function %s received extra arguments: %s",
                      deparse(substitute(fun)),
                      paste(extraArgs, collapse = ", ")))
  }

  return(aList)
}
