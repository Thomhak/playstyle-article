--[[
  ACM's production system (TAPS) accepts only acmart and the packages on its
  list, and the source must not load packages that acmart already loads.

  For every LaTeX document, Quarto's crossref and layout filters add
  conditional package loads to header-includes, e.g.
    \@ifpackageloaded{caption}{}{\usepackage{caption}}
  acmart loads caption and float, so those lines never load anything, and
  subcaption is only needed for sub-figures, which this manuscript does not
  use. This filter runs after Quarto's filters (at: post-render) and removes
  these lines so the generated .tex contains no \usepackage for them.
]]--

local drop = { caption = true, float = true, subcaption = true }

local function strip(text)
  return (text:gsub("\\@ifpackageloaded{(%w+)}{}{\\usepackage{%1}}\n?", function(pkg)
    if drop[pkg] then
      return ""
    end
  end))
end

local function strip_raw(el)
  if el.format == "latex" or el.format == "tex" then
    el.text = strip(el.text)
    return el
  end
end

return {
  {
    Meta = function(meta)
      local includes = meta["header-includes"]
      if not quarto.doc.is_format("latex") or pandoc.utils.type(includes) ~= "List" then
        return nil
      end
      for i, item in ipairs(includes) do
        local item_type = pandoc.utils.type(item)
        if item_type == "Blocks" or item_type == "Inlines" then
          includes[i] = item:walk({ RawBlock = strip_raw, RawInline = strip_raw })
        end
      end
      meta["header-includes"] = includes
      return meta
    end
  }
}
