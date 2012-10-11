/*global module:false*/
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib');

  grunt.initConfig({
    pkg: '<json:package.json>',
    lint: {
      files: ['grunt.js', 'lib/**/*.js', 'test/**/*.js']
    },
    coffee: {
      compile: {
        files: {
          'app.js': 'app.coffee'
        }
      }
    },
    concat: {
      dist: {
        src: [
            'public/javascripts/jquery.min.js', 
            'public/javascripts/codeflake.js'
        ],
        dest: 'public/javascripts/dist.js'
      }
    },
    min: {
      dist: {
        src: ['public/javascripts/dist.js'],
        dest: 'public/javascripts/dist.min.js'
      }
    },
    watch: {
      files: '<config:lint.files>',
      tasks: 'lint test'
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true
      },
      globals: {
        jQuery: true
      }
    },
    uglify: {}
  });
  grunt.registerTask('default', 'lint test concat min');
};
