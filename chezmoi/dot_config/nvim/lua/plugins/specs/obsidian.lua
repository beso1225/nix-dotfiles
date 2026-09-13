return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  ft = { "markdown", "md" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function ()
    require("obsidian").setup({
      workspaces = {
        {
          name = "iCloud",
          path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/beso1225",
        },
      },
      daily_notes = {
        folder = "002_Daily",
        date_format = "%Y-%m-%d",
        template = "daily.md",
      },
      templates = {
        subdir = "999_Templates",
        date_format = "%Y-%m-%d",
      },
      notes_subdir = "001_InBox",
      note_id_func = function (title)
        if title ~= nil then
          return title:gsub('[\\/:%*%?"<>|]', "")
        else
          return tostring(os.time())
        end
      end,
    })

    vim.api.nvim_create_user_command(
      "ObsidianNewNote",
      function (opts)
        local client = require("obsidian").get_client()
        local title = opts.args ~= "" and opts.args or tostring(os.time())

        local note = client:create_note({
          title = title,
          template = "note",
        })

        if note then
          client:open_note(note)
        end
      end,
      { nargs = "?" }
    )
  end
}
