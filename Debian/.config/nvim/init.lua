-- ======================================
-- Instalação e configuração do Lazy.nvim
-- ======================================

-- BOOTSTRAP LAZY.NVIM (NÃO DEVE SER ALTERADO)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- CONFIGURAÇÕES GERAIS E TECLAS LÍDER

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Numeração de linhas
--vim.cmd("syntax on")        -- Fallback de realce para o Treesitter
vim.opt.number = true         -- números à esquerda
vim.opt.relativenumber = true -- numeração híbrida
vim.opt.cursorline = true     -- Destaca a linha atual
vim.opt.termguicolors = true  -- Suporte a cores 24-bit no terminal
vim.opt.signcolumn = "yes"    -- Mantém a coluna lateral fixa

-- Integração e comandos
vim.opt.mouse = "a"               -- Habilita o mouse em todos os modos
vim.opt.clipboard = "unnamedplus" -- Integra à área de transferência do sistema
vim.opt.updatetime = 250          -- Tempo de resposta mais rápido para plugins e swap

-- Comportamento de busca
vim.opt.hlsearch = true   -- destaca resultados da busca
vim.opt.incsearch = true  -- Pula para o resultado digita
vim.opt.ignorecase = true -- ignorando maiúsculas 
vim.opt.smartcase = true  -- ...até que uma seja digitada

-- Área de transferência e interface
vim.opt.clipboard = "unnamedplus" -- Integra o Neovim a área de trabalho (wl-clipboard ou xclip)
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Identação (4 espaços para geral e 2 para yaml)
vim.opt.autoindent = true  -- Mantém a indentação da linha anterior
vim.opt.smartindent = true -- Entende chaves {} e indenta automaticamente
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4    -- Faz o Backspace apagar 4 espaços de uma vez
vim.opt.expandtab = true   -- Converte Tabs em espaços reais

-- Limpar destaque do hlsearch pressionando <Esc> no modo Normal
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- CONFIGURAÇÕES ESPECÍFICAS POR ARQUIVO

-- Grupo com `clear = true` para evitar duplicação ao recarregar o init.lua
local filetype_group = vim.api.nvim_create_augroup("ConfiguracoesPorArquivo", { clear = true })

-- Garante que arquivos .razor e .cshtml sejam reconhecidos corretamente pelo Neovim
vim.filetype.add({
  extension = {
    razor = "razor",
    cshtml = "razor",
  },
})

-- YAML (Docker/Podman), Lua e Front-end/Web (Blazor/Razor, JSON, HTML, CSS, JS) -> 2 espaços
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_group,
  pattern = { "yaml", "lua", "json", "html", "css", "javascript", "razor" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
  desc = "Define indentação de 2 espaços para Lua, YAML e Front-end/Blazor",
})

-- Markdown 
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_group,
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true      -- Quebra visualmente linhas longas
    vim.opt_local.linebreak = true -- Não quebra palavras ao meio no final da tela
    vim.opt_local.list = false     -- Equivalente ao 'setlocal nolist' (oculta caracteres invisíveis)
  end,
  desc = "Ajuste de quebra de linha para arquivos Markdown",
})

-- SETUP DE PLUGINS DO LAZY.NVIM

require("lazy").setup({
  spec = {
    -- add your plugins here
    -- Tema: Catppuccin
    {
	  "catppuccin/nvim",
	  name = "catppuccin",
	  lazy = false,
	  priority = 1000,
	  config = function()
	    vim.cmd.colorscheme("catppuccin-mocha")
	  end,
    },
    
    -- Treesitter (destaque de sintaxe e identação inteligente)
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master", -- Necessário para usar branch que possui a versão clássica estável (com módulo .configs)
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          -- Compila automaticamente os parsers das linguagens:
          ensure_installed = {
            "c_sharp",
            "lua",
            "vim",
            "vimdoc",
            "bash",
            "markdown",
            "markdown_inline",
            "yaml",
            "json",
            "html",
            "css",
            "javascript",
          },
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },
    
    -- Telescope (Finder para buscar arquivos e textos no projeto. Adaptativo para rodar em SOs com versões diferentes do Neovim)
    {
      "nvim-telescope/telescope.nvim",
      -- Se for Neovim 0.11+, usa 'master'. Se for 0.10 (Debian), usa '0.1.x'
      branch = vim.fn.has("nvim-0.11") == 1 and "master" or "0.1.x",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
        defaults = {
          preview = {
            -- No Neovim 0.10 com branch 0.1.x, desativa o treesitter no preview para evitar crash em .md
            treesitter = vim.fn.has("nvim-0.11") == 1,
          },
        },
      },
      keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar Arquivos" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar Texto (Ripgrep)" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Listar Buffers Abertos" },
      },
    },
    
    -- Wich-Key (Mostra um painel com os atalhos disponíveis ao apertar espaço)
    {
	  "folke/which-key.nvim",
	  event = "VeryLazy",
	  opts = {},
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- Tema provisório usado pela janela do Lazy enquanto baixa os plugins
  install = { colorscheme = { "catppuccin", "habamax" } },
  -- Verifica atualizações em segundo plano, mas sem notificações
  checker = { 
    enabled = true,
    notify = false,
  },
  -- Desativa o suporte ao luarocks/hererocks
  rocks = {
    enabled = false,
  },
})
