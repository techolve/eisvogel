-- Mermaid コードブロックを画像に変換する Lua フィルター
-- ```mermaid ... ``` ブロックを mmdc で PNG にレンダリングして埋め込む

local system = require 'pandoc.system'

local function render_mermaid(code, counter)
  return system.with_temporary_directory('mermaid', function(tmpdir)
    local infile  = tmpdir .. '/diagram.mmd'
    local outfile = tmpdir .. '/diagram.png'

    local f = io.open(infile, 'w')
    f:write(code)
    f:close()

    local ok = os.execute(
      'mmdc -i "' .. infile .. '" -o "' .. outfile ..
      '" -b transparent -p /techolve/filters/puppeteer-config.json -q 2>/dev/null'
    )
    if not ok then return nil end

    local img = io.open(outfile, 'rb')
    if not img then return nil end
    local data = img:read('*all')
    img:close()
    return data
  end)
end

local counter = 0

function CodeBlock(block)
  if not (block.classes[1] == 'mermaid') then return nil end

  counter = counter + 1
  local imgdata = render_mermaid(block.text, counter)
  if not imgdata then
    io.stderr:write('[mermaid] レンダリング失敗: mmdc が見つからないか実行エラー\n')
    return nil
  end

  local fname = 'mermaid-' .. counter .. '.png'
  pandoc.mediabag.insert(fname, 'image/png', imgdata)

  local caption = block.attributes['caption'] or ''
  return pandoc.Para({
    pandoc.Image(pandoc.read(caption).blocks[1] and
      pandoc.read(caption).blocks[1].content or {}, fname)
  })
end
