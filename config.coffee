exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo: 
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(?!app)/
      order:
        after: ['app/views/appView.js']

    stylesheets:
      joinTo: 'styles/app.css'
    
    templates:
      joinTo: 'javascripts/app.js'

  server: 
    path: 'appServer.coffee'
    port: 3333
    base: '/'
    run: yes

  plugins:
    autoReload:
      enabled:
        css: on
        js: on
        assets: off
       port: [1234, 2345, 3456]
      delay: 200 if require('os').platform() is 'win32'

  sourceMaps: false