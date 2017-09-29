# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions
require "lib/stories"

helpers Stories

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

 helpers do
   def surround_td(string)
     return format("<td>%s</td>",string)
   end

   def link_to_sheet(string)
     return format(%Q{<td><a href="sheets/%s.pdf" target="_blank"><span class="fa fa-file-pdf-o" aria-hidden="true"></span></a></td>},string)
   end
 end

 #set :icons_dir, '/'  # change the output dir

 ignore '.*' # ignore hidden files

# Build-specific configuratio
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end
