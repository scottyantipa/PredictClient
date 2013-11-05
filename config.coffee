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
    path: 'app.coffee'
    port: 3333
    base: '/'
    run: yes