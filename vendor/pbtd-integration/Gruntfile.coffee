module.exports = (grunt) ->

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-slim"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-sftp-deploy"
  grunt.loadNpmTasks "grunt-contrib-copy"

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    slim: # Task
      build: # Target
        files: # Dictionary of files
          "build/index.html": "src/index.slim"

    stylus:
      build:
        files:
          "build/style.css": "src/style.styl"
        options:
          banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd, HH:mm") %> */\n'
          compress: true

    uglify:
      build:
        files: [
          expand: true
          cwd: "src/scripts"
          src: "**/*.js"
          dest: "build/scripts"
        ]

    copy:
      build:
        expand: true
        cwd: "src/images/"
        src: ["**/*.{png,jpg,gif}"]
        dest: "build/images/"

    watch:
      build:
        files: ["src/**/*"]
        tasks: ["slim", "stylus", "uglify"]

  # Default task(s).
  grunt.registerTask "default", ["watch"]
  grunt.registerTask "build", ["slim", "stylus", "uglify", "copy"]
