#
# Cookbook Name:: gulp
#
# Recipe:: default
#

nodejs_npm "install --global gulp"
nodejs_npm "install --save-dev gulp"
nodejs_npm "install gulp-autoprefixer  gulp-livereload gulp-csso gulp-imagemin gulp-uglify gulp-concat --save-dev"
