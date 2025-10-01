url <- "https://datasus-ftp-mirror.nyc3.digitaloceanspaces.com/rclone_datasus_log.txt"

res <- tibble::tibble(
  log_info = readr::read_lines(url)
) |>
  dplyr::filter(!log_info == "") |>
  dplyr::filter(!stringr::str_equal(log_info, "-e ")) |>
  dplyr::filter(!stringr::str_starts(log_info, "Transferred:")) |>
  dplyr::filter(!stringr::str_starts(log_info, "Checks:")) |>
  dplyr::filter(!stringr::str_starts(log_info, "Elapsed time:")) |>
  dplyr::filter(
    !stringr::str_detect(log_info, "There was nothing to transfer")
  ) |>
  dplyr::filter(!stringr::str_ends(log_info, "INFO  : ")) |>
  dplyr::filter(!stringr::str_starts(log_info, "Checking:")) |>
  dplyr::filter(!stringr::str_starts(log_info, " \\*")) |>
  dplyr::filter(!stringr::str_starts(log_info, "Transferring:")) |>
  dplyr::mutate(
    system = dplyr::case_when(
      stringr::str_detect(log_info, "-e SIM files") ~ "SIM",
      stringr::str_detect(log_info, "-e SINASC files") ~ "SINASC",
      stringr::str_detect(log_info, "-e SIH files") ~ "SIH",
      stringr::str_detect(log_info, "-e SIA files") ~ "SIA",
      stringr::str_detect(log_info, "-e SINAN files") ~ "SINAN",
      stringr::str_detect(log_info, "-e CNES files") ~ "CNES",
      stringr::str_detect(log_info, "-e ESUSNOTIFICA files") ~ "ESUSNOTIFICA",
      stringr::str_detect(log_info, "-e DADOSABERTOS files") ~ "DADOSABERTOS",
      .default = NA
    )
  ) |>
  dplyr::mutate(
    path = dplyr::case_when(
      stringr::str_detect(log_info, " INFO  : ") ~
        stringr::str_sub(log_info, 29, 1000000)
    ),
    path = stringr::str_extract(path, ".*(?=\\:)"),
    file = fs::path_file(path)
  ) |>
  dplyr::mutate(
    action = dplyr::case_when(
      stringr::str_ends(log_info, stringr::fixed("Copied (new)")) ~ "New",
      stringr::str_ends(
        log_info,
        stringr::fixed("Copied (replaced existing)")
      ) ~
        "Replaced",
      stringr::str_ends(log_info, stringr::fixed("Deleted")) ~ "Deleted",
      .default = NA
    )
  ) |>
  dplyr::mutate(date = anytime::anydate(stringr::str_squish(log_info[1]))) |>
  dplyr::select(date, system, path, file, action) |>
  tidyr::fill(system, .direction = "down") |>
  na.omit()

if (nrow(res) > 0) {
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "rclone_logs.duckdb")
  DBI::dbWriteTable(con, name = "logs", value = res, append = TRUE)
  DBI::dbDisconnect(con)
}
