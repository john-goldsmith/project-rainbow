gulp = require "gulp"
$ = require("gulp-load-plugins")(
  pattern: "*"
)

config =
  paths:
    jade: "src/views/**/*.jade"
    sass: "src/styles/**/*.sass"
    coffee: "src/scripts/**/*.coffee"
    dist: "./dist"

gulp.task "default", ["build"], ->

# Compile Jade
gulp.task "jade", ->
  gulp.src config.paths.jade
    .pipe $.jade()
    .pipe gulp.dest config.paths.dist

# Compile Sass
gulp.task "sass", ->
  gulp.src config.paths.sass
    .pipe $.sass
      indentedSyntax: true
    .pipe $.minifyCss()
    .pipe $.rename suffix: ".min"
    .pipe gulp.dest config.paths.dist

# Compile Coffee
gulp.task "coffee", ->
  gulp.src config.paths.coffee
    .pipe $.coffee()
    .pipe $.concat "application.js"
    .pipe $.uglify()
    .pipe $.rename suffix: ".min"
    .pipe gulp.dest config.paths.dist

# Build distribution
gulp.task "build", ["clean", "watch", "jade", "sass", "coffee"], ->

gulp.task "clean", ->
  $.del config.paths.dist

gulp.task "watch", ->
  gulp.watch config.paths.jade, ["jade"]
  gulp.watch config.paths.sass, ["sass"]
  gulp.watch config.paths.coffee, ["coffee"]
