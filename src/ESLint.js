const ESLint = require("eslint");

exports.createLinter = function () {
  return new ESLint.Linter();
};

exports.createCLIEngine = function (options) {
  options = {
    useEslintrc: false,
  };
  return new ESLint.CLIEngine(options);
};

exports.executeOnTextImpl = function (cliEngine, text, fileName) {
  const result = cliEngine.executeOnText(text, fileName);

  return result;
};

exports.createRuleTester = function () {
  //
};

exports.verifyImpl = function (left, right, linter, linterConfig, code) {
  linterConfig = {
    rules: {
      semi: 2,
    },
  };

  try {
    const lintOptions = {};
    const messages = linter.verify(code, linterConfig, lintOptions);

    return right(messages);
  } catch (e) {
    left(e.toString());
  }
};

exports.eslint = null;
