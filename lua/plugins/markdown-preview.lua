return {
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = 'cd app && npm install && git checkout yarn.lock',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
  },
}
