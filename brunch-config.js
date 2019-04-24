// See http://brunch.io for documentation.
exports.files = {
  javascripts: {
    joinTo: {
      'app.js': /^src/,
      'vendor.js': /^(?!src)/
    }
  }
};

exports.plugins = {
  babel: {presets: ['latest']}
};

exports.paths = {
  public: 'app/assets/javascripts/lit',
  watched: ['src']
};