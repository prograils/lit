// See http://brunch.io for documentation.
exports.npm = {
  styles: {
    pell: ['dist/pell.css']
  }
};

exports.files = {
  javascripts: {
    joinTo: {
      'javascripts/lit/app.js': /^src/,
      'javascripts/lit/vendor.js': /^(?!src)/
    }
  },
  stylesheets: {
    joinTo: {
      'stylesheets/lit/app.css': /^src/,
      'stylesheets/lit/vendor.css': /^(?!src)/
    }
  }
};

exports.plugins = {
  babel: {presets: ['latest']}
};

exports.paths = {
  public: 'app/assets',
  watched: ['src']
};