const { environment } = require('@rails/webpacker')

const webpack = require('webpack');

// Add an additional plugin to provide $ and jQuery to Bootstrap
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
  })
);

module.exports = environment;

module.exports = environment
