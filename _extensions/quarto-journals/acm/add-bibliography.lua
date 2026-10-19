
function has_class(el, class)
  if el.attr == nil then
    return nil
  end
  for i,v in ipairs(el.attr.classes) do
    if v == class then
      return true
    end
  end
  return false
end

function get_block_with_class(el, class)
  return find_node(el, function(el)
    return has_class(el, class)
  end)
end

function get_image(el)
  return find_node(el, function (v)
    return v.t == "Image"
  end)
end

function attribute(el, name, default)
  for k,v in pairs(el.attr.attributes) do
    if k == name then
      return v
    end
  end
  return default
end

function replace_node(blocks, predicate, replacement)
  for i, el in pairs(blocks) do
    if predicate(el) then      
      table.remove(blocks, i)
      if type(replacement) == "function" then
        replacement = replacement(el)
      end
      table.insert(blocks, i, replacement)
      return el
    end
  end
  return nil
end

local bibname = ''

return {
  {
    Meta = function(meta)
      for _i, v in ipairs(meta.bibliography) do
        if bibname ~= '' then
          bibname = bibname .. ','
        end
        bibname = bibname .. pandoc.utils.stringify(v)
      end
      
    end,
    Pandoc = function(doc)
      if not quarto.doc.is_format("latex") then
        return doc
      end

      -- add bibliography to the right place
      --
      -- With `cite-method: natbib`, Quarto itself replaces a `::: {#refs}`
      -- div with `\renewcommand{\bibsection}{}\bibliography{...}` (empty
      -- \bibsection, so the heading must come from the Markdown header), and
      -- it already emits `\bibliographystyle{<biblio-style>}` in the preamble
      -- (biblio-config partial). Emitting our own \bibliography as well
      -- printed the reference list twice and made BibTeX report "Illegal,
      -- another \bibstyle/\bibdata command". So:
      --   * refs div present: leave placement to Quarto and only make the
      --     "References" header unnumbered (same output as acmart's own
      --     \bibsection: \section*{References} + TOC entry);
      --   * no refs div: fall back to replacing the "References" header with
      --     \bibliography{...}; acmart's \bibsection then prints the heading.
      --     No \bibliographystyle here, the preamble already sets it.
      local has_refs_div = false
      doc:walk({
        Div = function(el)
          if el.identifier == "refs" then
            has_refs_div = true
          end
        end
      })
      local is_references_header = function(el)
        return el.t == "Header" and pandoc.utils.stringify(el.content) == "References"
      end
      if has_refs_div then
        for _i, el in ipairs(doc.blocks) do
          if is_references_header(el) and not has_class(el, "unnumbered") then
            el.classes:insert("unnumbered")
          end
        end
      else
        local bibliography = pandoc.RawBlock(
          "latex", "\\bibliography{" .. bibname .. "}")
        replace_node(doc.blocks, is_references_header, bibliography)
      end

      -- fix appendix compilation
      local appendix = pandoc.RawBlock("latex", "\\appendix")
      replace_node(doc.blocks, function(el)
        return el.t == "Header" and pandoc.utils.stringify(el.content) == "Appendix"
      end, appendix)

      -- fix acknowledgments
      replace_node(doc.blocks, function(el)
        return el.t == "Div" and has_class(el, "acks")
      end, function(el)
        local text = pandoc.write(pandoc.Pandoc(el.content), "latex")
        local node = pandoc.RawBlock(
          "latex", "\\begin{acks}\n" .. text .. "\n\\end{acks}")
        return node        
      end)

      return doc
    end
  }
}
