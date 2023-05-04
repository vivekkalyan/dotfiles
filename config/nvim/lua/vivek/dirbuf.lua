local status_ok, dirbuf = pcall(require, "dirbuf")
if not status_ok then
  return
end

dirbuf.setup {
    hash_padding = 2,
    show_hidden = true,
    sort_order = "directories_first",
    write_cmd = "DirbufSync -confirm",
}
