-- This is the prompt module function.
local function k8s_module(args)
    -- todo make this async to not slow the prompt down

    local ns = "default"
    local context = ""
    local p = io.popenyield("kubectl.exe config view --minify 2>nul", "rt")
    for line in p:lines() do
        local m = line:match(" *namespace: (.+)$")
        if m then
          ns = m
          break
        end
    end
    if (p:close() == nill ) then
      -- kubectl not found
      return
    end

    p = io.popenyield("kubectl.exe config current-context 2>nul", "rt")
    for line in p:lines() do
        local m = line:match("(.+)$")
        if m then
            context = m
            break
        end
    end
    p:close()

    text = flexprompt.append_text(flexprompt.get_symbol("kubernetes", '☸'), context)
    text = flexprompt.append_text(text, ns)
    
    -- Set up the default colors, and then parse a 'color' token to override the
    -- defaults with customized colors.
    local color = "magenta"
    local altcolor = "black"
    local color_arg = flexprompt.parse_arg_token(args, "color")
    color, altcolor = flexprompt.parse_colors(color_arg, color, altcolor)

    return text, color, altcolor
end

-- This registers the prompt module function with flexprompt.
-- Pass a string, and a function.
-- In your prompt, refer to the prompt module by putting its name inside
-- squiggly braces, such as "{mfm}" in this example.
flexprompt.add_module("k8s", k8s_module)