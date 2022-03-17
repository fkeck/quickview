
#' Open data in a View tab or in external software
#'
#' @keywords internal
#' @importFrom rstudioapi getActiveDocumentContext
#' @importFrom stringr str_count
#'
#' @name quickview
"_PACKAGE"


#' Open data in a View tab
#'
#' @export)
#'
qv_view <- function() {
  block <- get_block()
  comm <- paste0('View(', block, ')')
  print_screen_msg(block)
  eval(parse(text = comm))
}


#' Open data with default CSV/text editor
#'
#' @export
#'
qv_open <- function() {

  block <- get_block()

  eval_block <- eval(parse(text = block))

  skip_col_names <-
    (is.atomic(eval_block) && is.null(dim(eval_block))) |
    (is.matrix(eval_block) && is.null(colnames(eval_block))) |
    (is.array(eval_block) && length(dim(eval_block)) == 1)

  skip_row_names <-
    (is.atomic(eval_block) && is.null(attributes(eval_block))) |
    (is.matrix(eval_block) && is.null(rownames(eval_block))) |
    (is.factor(eval_block)) |
    (is.array(eval_block) && length(dim(eval_block)) == 1 && is.null(names(eval_block)))



  if(!is.data.frame(eval_block) & !is.matrix(eval_block) & !is.atomic(eval_block)) {

    eval_block <- tryCatch(as.data.frame(eval_block), error = function(e) eval_block)

  }

  if(!is.data.frame(eval_block) & !is.matrix(eval_block) & !is.atomic(eval_block)) {

    eval_block <- tryCatch(as.character(eval_block), error = function(e) eval_block)

  }


  # IF object is dataframe, matrix or vector of length > 1
  if(is.data.frame(eval_block) |
     is.matrix(eval_block) |
     (is.atomic(eval_block) & length(eval_block) > 1)) {

    ff <- tempfile(pattern = "quickview_", fileext = ".csv")
    eval_block <- as.data.frame(eval_block)

    if(!skip_row_names && !skip_col_names) {

      write.csv(eval_block, ff)

    } else if (!skip_row_names && skip_col_names) {

      write.table(eval_block, ff, col.names = FALSE, row.names = TRUE, sep = ",")

    } else if (skip_row_names && !skip_col_names) {

      write.table(eval_block, ff, col.names = TRUE, row.names = FALSE, sep = ",")

    } else {

      write.table(eval_block, ff, col.names = FALSE, row.names = FALSE, sep = ",")

    }

  # IF object is vector of length 1
  } else if (is.atomic(eval_block) & length(eval_block) == 1) {
    ff <- tempfile(pattern = "quickview_", fileext = ".txt")
    writeLines(as.character(eval_block), ff)

  # ELSE error
  } else {
    stop("Object not supported.")
  }

  comm <- paste0('browseURL("', ff, '")')
  print_screen_msg(block)
  eval(parse(text = comm))

}


#' Open working directory with the file manager
#'
#' @export
#'
qv_wd <- function() {
  comm <- paste0('browseURL("', getwd(), '")')
  eval(parse(text = comm))
}

# Find blocks of code in a character vector returned by
# rstudioapi::getActiveDocumentContext()$content
detect_com <- function(x){

  regex_op <- "(\\+|-|\\*|/|\\^|%|:|\\$|@|%|<|>|=|!|&|\\||~|,) *$"
  debt_par <- cumsum(sapply(x, stringr::str_count, pattern = "\\(") - sapply(x, stringr::str_count, pattern = "\\)"))
  debt_sqb <- cumsum(sapply(x, stringr::str_count, pattern = "\\[") - sapply(x, stringr::str_count, pattern = "\\]"))

  blocks <- vector("integer", length(x))
  k <- 1L
  for(i in seq_along(blocks)){
    if(debt_par[i] != 0 || debt_sqb[i] != 0 || grepl(regex_op, x[i]) || grepl("^ *$", x[i]) ) {
      blocks[i] <- k
    } else {
      blocks[i] <- k
      k <- k + 1L
    }
  }
  return(blocks)

}


# Uses the RStudio API to get the document context
# And returns the active/selected block of code
get_block <- function() {

  context <- rstudioapi::getActiveDocumentContext()

  if (identical(context$selection[[1]]$range$start,
                context$selection[[1]]$range$end)) {

    active_row <- context$selection[[1]]$range$start["row"]

    if(grepl("^ *$", context$contents[active_row])){
      return(invisible(0L))
    }

    context_com <- detect_com(context$contents)
    block_id <- context_com[active_row]
    block <- context$contents[context_com == block_id]
    block <- paste(block, collapse = "\n")

  } else {
    block <- context$selection[[1]]$text
  }
  return(block)
}


print_screen_msg <- function(x) {

  if(getOption("quickview.print", default = "default") == "default") {
    msg <- strsplit(x, split = "\n")[[1]]
    msg_len <- length(msg)
    if(msg_len > 12) {
      msg <- paste(msg[1:12], collapse = "\n")
      msg <- paste(msg, "\n\n[\033[3m...with", msg_len - 12, "more lines...\033[23m]")
    } else {
      msg <- paste(msg, collapse = "\n")
    }
    msg <- paste0("\033[90m", msg, "\033[39m")
    msg_header <- paste0("\033[40m\033[37m\033[1m",
                         "            QuickView            ",
                         "\033[22m\033[39m\033[49m")
    msg <- paste("\n", msg_header, "\n", msg, "\n\n")
    cat(msg)
  }
  #else : alternative print options
}
