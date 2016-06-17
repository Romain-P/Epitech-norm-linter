module.exports = EpitechNormLinter =
  config:
    a_pythonPath:
      title: 'Python Executable Path'
      type: 'string'
      description: 'Path to Python. Edit this only if Epitech-norm-linter doesn\'t work by default. If so, use another version of Python.\n\nEg: Python2, Python3.3, Python3.4, Python3.5 etc...'
      default: 'python3'
    b_lintOnFly:
      title: 'Lint on fly'
      description: 'When enabled, lints your code while typing. When disabled, lints your code while saving.'
      type: 'boolean'
      default: true
    c_verifyComment:
      title: 'Enable comments verification'
      description: 'Counts comments as a norm error, and displays a message.'
      type: 'boolean'
      default: true
    e_verifyLibc:
      title: 'Verify libc functions'
      description: 'Will search for some libc forbidden functions.\n\nThe forbidden functions are: printf, atof, atoi, atol, strcmp, strlen, strcat, strncat, strncmp, strcpy, strncpy, fprintf, strstr, strtoc, sprintf, asprintf, perror, strtod, strtol, strtoul.'
      type: 'boolean'
      default: true
    f_showDebug:
      title: 'Print logs on console'
      description: 'Enable this only if you\'re having an issue and want to help the developer solve it.'
      type: 'boolean'
      default: false
    g_useYan:
      title: 'Use Yan'
      description: 'Use <a href="https://github.com/motet-a/yan">Yan</a> instead of the default style checker. This will disable the previous options "Verify libc functions" and "Disable comments verification". Headers file must be in the root project\'s directory, or in a sub-folder include/inc.'
      type: 'boolean'
      default: false

  activate: ->
    require('atom-package-deps').install 'epitech-norm-linter'

  provideLinter: ->
    LinterProvider = require('./provider')
    @provider = new LinterProvider()
    return {
      grammarScopes: ['source.c']
      scope: 'file'
      lint: @provider.lint
      lintOnFly: true
    }
