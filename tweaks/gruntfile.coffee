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
      dist: ['dist/', 'dist-v2/']

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
    shell:
      copyV2: 'rsync -a dist/ dist-v2 && rm dist/manifest-v2.json && mv dist-v2/manifest-v2.json dist-v2/manifest.json'

  grunt.registerTask 'manifest', ->
    pkg = grunt.file.readJSON('package.json')
    manifest = {
      ...pkg.manifest
      version: pkg.version
      description: pkg.description
    }

    grunt.file.write 'dist/manifest.json', JSON.stringify manifest
    grunt.file.write 'dist/manifest-v2.json', JSON.stringify {
      ...manifest
      background: scripts: [ 'background.js' ]
      manifest_version: 2
    }
    grunt.log.ok()

  grunt.registerTask 'build', ->
    grunt.task.run ['clean', 'copy', 'manifest', 'coffee']
    grunt.task.run ['uglify'] if grunt.option('prod')
    grunt.task.run ['shell']

  grunt.registerTask 'add-psl', ->
    psl = execSync('cat $(which psl) | perl -lne \'last if m,// CLI,; print unless m,^#,\'')
    if psl?.length < 100
      grunt.log.error '`psl` command is missing, `clean-client-state` command will not work'
      return
    bg = grunt.file.read('dist/background.js')
    grunt.file.write('dist/background.js', psl + bg)
    grunt.log.ok()

  grunt.registerTask('dev', ['build', 'watch'])
