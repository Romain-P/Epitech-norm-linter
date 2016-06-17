child_process = require 'child_process'
path = require 'path'
fs = require 'fs'

module.exports = class LinterProvider

  useYan = () ->
    return atom.config.get 'epitech-norm-linter.g_useYan'

  getPythonPath = () ->
    return atom.config.get 'epitech-norm-linter.a_pythonPath'

  debug = () ->
    return atom.config.get 'epitech-norm-linter.f_showDebug'

  getYanArgs = (textEditor, fileName) ->
    return [
      "../norminette/yan.py",
      "-I" + atom.project.getPaths()[0] + "/include",
      "-I" + atom.project.getPaths()[0] + "",
      "-I" + atom.project.getPaths()[0] + "/inc",
      "--json",
      "-W",
      fileName
    ]

  getDefaultArgs = (fileName) ->
    args = [ "../norminette/norm.py", fileName, "-nocheat", "-malloc"];
    if (!atom.config.get 'epitech-norm-linter.c_verifyComment')
      args.push("-comment")
    if (atom.config.get 'epitech-norm-linter.e_verifyLibc')
      args.push("-libc")
    return args

  getIssueFromParams = (normChecker, linenb, msg, file) ->
    return (
      type: normChecker,
      text: "Faute de norme à la ligne " + linenb + ": " + msg,
      range: [[parseInt(linenb, 10) - 1, 9], [parseInt(linenb, 10) - 1, 1000000]],
      filePath: file)

  parseDefaultLinter = (textEditor, stdout) ->
    toReturn = [];
    for line in stdout.split('\n')
      if (line.match(/^Erreur/i))
        console.log("An error was found in file [" + textEditor.getPath() + "]");
        linenb = (line.split(' ')[6]).split(':')[0];
        error = (line.split(':')[1].split("=>")[0]);
        toReturn.push(getIssueFromParams("Norme", linenb, error, textEditor.getPath()))
    return toReturn;

  parseYanLinter = (textEditor, stdout) ->
    try
      yanIssues = JSON.parse(stdout)
      linterIssues = []
      for yanIssue, i in yanIssues
        if yanIssue.message == 'Yan comment directive'
          continue
        linterIssues.push(getIssueFromParams("Yan", yanIssue.position.line, yanIssue.message, textEditor.getPath()))
      return linterIssues

  onLinterExit = (textEditor, stdout, tmp, filePath) ->
    try
      if (tmp)
        fs.unlinkSync(filePath)
    if (debug())
      console.log("Norm checker output: " + stdout);
    if (useYan())
      return parseYanLinter(textEditor, stdout)
    else
      return parseDefaultLinter(textEditor, stdout)

  lintFile = (textEditor, filePath, tmp) =>
    return new Promise (resolve) ->
      output = ''
      options = {cwd: __dirname};
      args = [];
      if (useYan())
        args = getYanArgs(textEditor, filePath);
      else
        args = getDefaultArgs(filePath);
      if (debug())
        console.log("Epitech-norm-linter command: " + args);
      onExit = (error, stdout, stderr) ->
        resolve(onLinterExit(textEditor, stdout, tmp, filePath))
      process = child_process.execFile(getPythonPath(), args, options, onExit)

  lintOnFly = (textEditor) =>
    ext = path.extname(textEditor.getPath());
    pathTmp = __dirname + "/../norminette/" + textEditor.getTitle();
    fs.writeFileSync(pathTmp, textEditor.getText().toString())
    if (debug())
      console.log("File saved ! Path: " + pathTmp);
    lintFile(textEditor, pathTmp, true);

  lint: (textEditor) =>
    if (atom.config.get('epitech-norm-linter.b_lintOnFly'))
      pathTmp = lintOnFly(textEditor)
    else
      lintFile(textEditor, textEditor.getPath(), false)
