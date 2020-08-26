module.exports = function (grunt) {
  grunt.initConfig({
    babel: {
      options: {
        sourceMap: true,
        presets: ["@babel/preset-env"],
        plugins: ["transform-es2015-modules-commonjs"],
      },
      dist: {
        files: [
          {
            expand: true,
            cwd: "javascript/src",
            src: ["**/*.js"],
            dest: "inst/htmlwidgets/sources",
            ext: ".js",
          },
        ],
      },
      distSpecs: {
        files: [
          {
            expand: true,
            cwd: "javascript/tests",
            src: ["**/*.js"],
            dest: "inst/htmlwidgets/sources",
            ext: ".js",
          },
        ],
      },
    },
    browserify: {
      options: {
        browserifyOptions: {
          //debug: true
        },
      },
      dist: {
        files: {
          // if the source file has an extension of es6 then
          // we change the name of the source file accordingly.
          // The result file's extension is always .js
          "./inst/htmlwidgets/leaflet.js": [
            "./inst/htmlwidgets/sources/index.js",
          ],
        },
      },
    },
    eslint: {
      target: ["./javascript/src/*.js"],
    },
    mochaTest: {
      test: {
        options: {
          reporter: "spec",
          require: ["babel-register", "source-map-support/register"],
          // captureFile: 'results.txt', // Optionally capture the reporter output to a file
          quiet: false, // Optionally suppress output to standard out (defaults to false)
          clearRequireCache: false, // Optionally clear the require cache before running tests (defaults to false)
        },
        src: ["inst/htmlwidgets/sources/test-*.js"],
      },
    },
    watch: {
      scripts: {
        files: ["./javascript/src/**/*.js", "javascript/tests/**/*.js"],
        tasks: ["babel", "browserify", "eslint", "mochaTest"],
      },
    },
  });

  grunt.loadNpmTasks("grunt-babel");
  grunt.loadNpmTasks("grunt-browserify");
  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-eslint");
  grunt.loadNpmTasks("grunt-mocha-test");

  grunt.registerTask("default", ["watch"]);
  grunt.registerTask("build", ["babel", "browserify", "eslint", "mochaTest"]);
};
