{ execSync } = require 'child_process'

module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  fileOpts =
    expand: true
    cwd: '.'
    dest: 'dist/'

  grunt.initConfig
    copy:
      assets: {
        ...fileOpts
        src: ['*.png']
      }

    clean:
      dist: ['dist/']

    watch:
      src:
        files: ['*']
        tasks: ['build']

    coffee:
      compile:
        options:
          sourceMap: not grunt.option('prod')
          bare: true
        files: [{
          ...fileOpts
          src: ['*.coffee', '!gruntfile.coffee']
          ext: '.js'
        }]

    uglify:
      dist:
        files: [
          expand: true
          cwd: 'dist'
          dest: 'dist/'
          src: '*.js'
        ]

  grunt.registerTask 'manifest', ->
    pkg = grunt.file.readJSON('package.json')
    grunt.file.write 'dist/manifest.json', JSON.stringify {
      ...pkg.manifest
      version: pkg.version
      description: pkg.description
    }
    grunt.log.ok()

  grunt.registerTask 'build', ->
    grunt.task.run ['clean', 'copy', 'manifest', 'coffee', 'add-psl']
    grunt.task.run ['uglify'] if grunt.option('prod')

  grunt.registerTask 'add-psl', ->
    psl = execSync('cat $(which psl) | perl -lne \'last if m,// CLI,; print unless m,^#,\'')
    if psl?.length < 100
      grunt.log.error '`psl` command is missing, `clean-client-state` command will not work'
      return
    bg = grunt.file.read('dist/background.js')
    grunt.file.write('dist/background.js', psl + bg)
    grunt.log.ok()

  grunt.registerTask('dev', ['build', 'watch'])
