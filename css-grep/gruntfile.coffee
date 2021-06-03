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
        src: [
          'active.png'
          'inactive.png'
        ]
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
          transpile:
            presets: ['env']
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
    grunt.task.run ['clean', 'copy', 'manifest', 'coffee']
    grunt.task.run ['uglify'] if grunt.option('prod')

  grunt.registerTask('dev', ['build', 'watch'])
