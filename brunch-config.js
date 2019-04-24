// See http://brunch.io for documentation.
exports.files = {
  javascripts: {
    joinTo: {
      'app.js': /\.js$/
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