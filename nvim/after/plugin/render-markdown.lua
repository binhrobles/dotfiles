require('render-markdown').setup({
  heading = {
    width = 'block',
    backgrounds = {
      'RenderMarkdownH1Bg',
      'RenderMarkdownH2Bg',
      'RenderMarkdownH3Bg',
      '',
      'RenderMarkdownH5Bg',
      'RenderMarkdownH6Bg',
    },
    foregrounds = {
      'RenderMarkdownH1',
      'RenderMarkdownH2',
      'RenderMarkdownH3',
      '',
      'RenderMarkdownH5',
      'RenderMarkdownH6',
    },
  },
})
