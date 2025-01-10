return {
    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPost', 'BufNewFile' },
        config = function()
            require('plugins.lspconf.lsp-config')
        end,
    },

}
