local status_ok, comment = pcall(require, "mini.comment")
if not status_ok then
  return
end

comment.setup()
