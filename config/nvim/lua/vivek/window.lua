local M = {}

function M.win_move(key)
    local curwin = vim.api.nvim_get_current_win()
    vim.api.nvim_command("wincmd " .. key)
    if curwin == vim.api.nvim_get_current_win() then
        if string.match(key, '[jk]') then
            vim.api.nvim_command("wincmd s")
        else
            vim.api.nvim_command("wincmd v")
        end
        vim.api.nvim_command("wincmd " .. key)
    end
end

return M
