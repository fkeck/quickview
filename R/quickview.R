
#' Open datasets in a View tab
#'
#' @keywords internal
#' @importFrom rstudioapi getActiveDocumentContext
#'
#' @name quickview
"_PACKAGE"


#' Open datasets in a View tab
#'
#' @export
#'
quickview <- function() {
  context <- rstudioapi::getActiveDocumentContext()

  if (identical(context$selection[[1]]$range$start,
                context$selection[[1]]$range$end)) {

    last_row <- context$selection[[1]]$range$start["row"]
    first_row <- last_row
    while (first_row > 1 && (grepl("(\\+|%>%) *$", context$contents[first_row - 1]) ||
                             grepl("^ +$", context$contents[first_row - 1]) ||
                             context$contents[first_row - 1] == "")) {
      first_row <- first_row - 1
    }

    while (last_row <= length(context$contents) && (grepl("(\\+|%>%) *$", context$contents[last_row])  ||
                                                    grepl("^ +$", context$contents[last_row]) ||
                                                    context$contents[last_row] == "")) {
        last_row <- last_row + 1

    }

    block <- context$contents[seq.int(first_row, last_row)]
    block <- paste(block, collapse = " ")

  } else {
    block <- context$selection[[1]]$text
  }

  comm <- paste0('View(', block, ')')
  print(comm)
  eval(parse(text = comm))

}



