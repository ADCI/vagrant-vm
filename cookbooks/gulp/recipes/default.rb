#
# Cookbook Name:: gulp
#
# Recipe:: default
#

nodejs_npm "gulp"
nodejs_npm "gulp-autoprefixer"
nodejs_npm "gulp-livereload"
nodejs_npm "gulp-csso"
nodejs_npm "gulp-imagemin"
nodejs_npm "gulp-uglify"
nodejs_npm "gulp-concat"

bash 'install_gulp_local'  do
  code "su #{node['gulp']['user']} -l -c 'npm install --save-dev gulp'"
end

bash 'install_gulp_plugins'  do
  code "su #{node['gulp']['user']} -l -c 'npm install gulp-autoprefixer  gulp-livereload gulp-csso gulp-imagemin gulp-uglify gulp-concat --save-dev'"
end